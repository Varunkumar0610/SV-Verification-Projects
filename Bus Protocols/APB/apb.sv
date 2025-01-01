module apb_s
(
    input  logic pclk,
    input  logic presetn,
    input  logic [31:0] paddr,
    input  logic psel,
    input  logic penable,
    input  logic [7:0] pwdata,
    input  logic pwrite,
    
    output logic [7:0] prdata,
    output logic pready,
    output logic pslverr
);

  // State definitions
  localparam [1:0] IDLE = 2'b00, WRITE = 2'b01, READ = 2'b10;

  // Internal signals
  reg [1:0] state, nstate;
  reg [7:0] mem [15:0];  // 16 memory locations
  logic addr_err, data_err;

  // Reset and state transition
  always_ff @(posedge pclk or negedge presetn) begin
    if (!presetn)
      state <= IDLE;
    else
      state <= nstate;
  end

  // Next state logic and output logic
  always_comb begin
    // Default values
    nstate = state;
    pready = 1'b0;
    prdata = 8'h00;
    addr_err = 1'b0;
    data_err = 1'b0;

    case (state)
      IDLE: begin
        if (psel) begin
          if (pwrite)
            nstate = WRITE;
          else
            nstate = READ;
        end
      end

      WRITE: begin
        if (psel && penable) begin
          addr_err = (paddr > 15); // Address range check
          if (!addr_err) begin
            mem[paddr] = pwdata;
          end
          pready = 1'b1;
          nstate = IDLE;
        end
      end

      READ: begin
        if (psel && penable) begin
          addr_err = (paddr > 15); // Address range check
          if (!addr_err) begin
            prdata = mem[paddr];
          end
          else begin
            prdata = 8'h00; // Default invalid data
          end
          pready = 1'b1;
          nstate = IDLE;
        end
      end

      default: begin
        nstate = IDLE;
      end
    endcase
  end

  // Error signal generation
  assign pslverr = (psel && penable) && addr_err;

endmodule

interface abp_if;
  logic pclk;
  logic presetn;
  logic [31:0] paddr;    // Address
  logic [7:0] pwdata;    // Write Data
  logic [7:0] prdata;    // Read Data
  logic pwrite;          // Write Enable
  logic psel;            // Select
  logic penable;         // Enable
  logic pready;          // Ready
  logic pslverr;         // Slave Error

  // Modports for testbench roles
  modport driver (
    input pclk, presetn,
    output paddr, pwdata, pwrite, psel, penable
  );

  modport monitor (
    input pclk, presetn, prdata, pready, pslverr
  );

endinterface
