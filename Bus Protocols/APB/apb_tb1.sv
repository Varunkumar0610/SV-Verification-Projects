class transaction;

  rand bit [31:0] paddr;
  rand bit [7:0] pwdata;
  rand bit psel;
  rand bit penable;
  randc bit pwrite;
  bit [7:0] prdata;
  bit pready;
  bit pslverr;

  constraint addr_c {
    paddr >= 0; paddr <= 15;
  }

  constraint data_c {
    pwdata >= 0; pwdata <= 255;
  }

  function void display(input string tag);
    $display("[%0s] :  paddr:%0d  pwdata:%0d pwrite:%0b  prdata:%0d pslverr:%0b @ %0t", tag, paddr, pwdata, pwrite, prdata, pslverr, $time);
  endfunction

endclass

/////////////////////////////////////////////////

class generator;

  transaction tr;
  mailbox #(transaction) mbx;
  int count = 0;

  event nextdrv;  // driver completed task of triggering interface
  event nextsco;  // scoreboard completed its objective
  event done;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction;

  task run();
    repeat(count) begin
      assert(tr.randomize()) else $error("Randomization failed");
      mbx.put(tr);
      tr.display("GEN");
      @(nextdrv);
      @(nextsco);
    end
    ->done;
  endtask

endclass

/////////////////////////////////////////////////////

class driver;

  virtual apb_if vif;
  mailbox #(transaction) mbx;
  transaction datac;

  event nextdrv;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction;

  task reset();
    vif.presetn <= 1'b0;
    vif.psel <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwdata <= 0;
    vif.paddr <= 0;
    vif.pwrite <= 1'b0;
    repeat(5) @(posedge vif.pclk);
    vif.presetn <= 1'b1;
    $display("[DRV] : RESET DONE");
    $display("----------------------------------------------------------------------------");
  endtask

  task run();
    forever begin
      mbx.get(datac);
      @(posedge vif.pclk);
      if (datac.pwrite == 1) begin  // write
        vif.psel <= 1'b1;
        vif.penable <= 1'b0;
        vif.pwdata <= datac.pwdata;
        vif.paddr <= datac.paddr;
        vif.pwrite <= 1'b1;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        @(posedge vif.pclk);
        vif.psel <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite <= 1'b0;
        datac.display("DRV");
        ->nextdrv;
      end else if (datac.pwrite == 0) begin  // read
        vif.psel <= 1'b1;
        vif.penable <= 1'b0;
        vif.pwdata <= 0;
        vif.paddr <= datac.paddr;
        vif.pwrite <= 1'b0;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        @(posedge vif.pclk);
        vif.psel <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite <= 1'b0;
        datac.display("DRV");
        ->nextdrv;
      end
    end
  endtask

endclass

/////////////////////////////////////////////////////

class monitor;

  virtual apb_if vif;
  mailbox #(transaction) mbx;
  transaction tr;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction;

  task run();
    tr = new();
    forever begin
      @(posedge vif.pclk);
      if (vif.pready) begin
        tr.pwdata = vif.pwdata;
        tr.paddr = vif.paddr;
        tr.pwrite = vif.pwrite;
        tr.prdata = vif.prdata;
        tr.pslverr = vif.pslverr;
        @(posedge vif.pclk);
        tr.display("MON");
        mbx.put(tr);
      end
    end
  endtask

endclass

/////////////////////////////////////////////////////

class scoreboard;

  mailbox #(transaction) mbx;
  transaction tr;
  event nextsco;

  bit [7:0] pwdata[16] = '{default:0};
  bit [7:0] rdata;
  int err = 0;

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction;

  task run();
    forever begin
      mbx.get(tr);
      tr.display("SCO");

      if ((tr.pwrite == 1'b1) && (tr.pslverr == 1'b0)) begin  // write access
        pwdata[tr.paddr] = tr.pwdata;
        $display("[SCO] : DATA STORED DATA : %0d ADDR: %0d", tr.pwdata, tr.paddr);
      end else if ((tr.pwrite == 1'b0) && (tr.pslverr == 1'b0)) begin  // read access
        rdata = pwdata[tr.paddr];
        if (tr.prdata == rdata)
          $display("[SCO] : Data Matched");
        else begin
          err++;
          $display("[SCO] : Data Mismatched");
        end
      end else if (tr.pslverr == 1'b1) begin
        $display("[SCO] : SLV ERROR DETECTED");
      end
      $display("---------------------------------------------------------------------------------------------------");
      ->nextsco;
    end
  endtask

endclass

/////////////////////////////////////////////////////

class environment;

  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;

  event nextgd;  // gen -> drv
  event nextgs;  // gen -> sco

  mailbox #(transaction) gdmbx;  // gen - drv
  mailbox #(transaction) msmbx;  // mon - sco

  virtual apb_if vif;

  function new(virtual apb_if vif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);

    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);

    this.vif = vif;
    drv.vif = this.vif;
    mon.vif = this.vif;

    gen.nextsco = nextgs;
    sco.nextsco = nextgs;

    gen.nextdrv = nextgd;
    drv.nextdrv = nextgd;
  endfunction

  task pre_test();
    drv.reset();
  endtask

  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask

  task post_test();
    wait(gen.done.triggered);
    $display("----Total number of Mismatch : %0d------", sco.err);
    $finish();
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask

endclass

interface apb_if(
  input logic pclk,  // Clock signal
  input logic presetn // Reset signal
);

  logic [31:0] paddr;    // Address
  logic [7:0] pwdata;    // Write Data
  logic [7:0] prdata;    // Read Data
  logic pwrite;          // Write Enable
  logic psel;            // Select
  logic penable;         // Enable
  logic pready;          // Ready
  logic pslverr;         // Slave Error

  // Clocking block for synchronous access
  clocking cb @(posedge pclk);
    input prdata, pready, pslverr;
    output paddr, pwdata, pwrite, psel, penable;
  endclocking

endinterface


//////////////////////////////////////////////////

// Testbench Module
module tb;

  // Interface instantiation
  apb_if vif();

  // DUT instantiation
  apb_s dut (
    .pclk(vif.pclk),
    .presetn(vif.presetn),
    .paddr(vif.paddr),
    .psel(vif.psel),
    .penable(vif.penable),
    .pwdata(vif.pwdata),
    .pwrite(vif.pwrite),
    .prdata(vif.prdata),
    .pready(vif.pready),
    .pslverr(vif.pslverr)
  );

  // Clock generation
  initial begin
    vif.pclk = 0;
  end

  always #10 vif.pclk = ~vif.pclk;

  // Environment instantiation
  environment env;

  initial begin
    // Environment setup
    env = new(vif);
    env.gen.count = 20; // Number of transactions
    env.run();          // Start the test
  end

  // Dump file for waveform analysis
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb); // Include all signals in the waveform
  end

endmodule