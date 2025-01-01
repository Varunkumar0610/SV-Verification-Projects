# Makefile for DFF SV Project

# SIMULATOR options: Questa (Mentor Questasim) or VCS (Synopsys VCS)
SIMULATOR = VCS

# Directory Paths
RTL_DIR = ../rtl
TB_DIR = ../tb
SIM_DIR = ../sim

# Files
RTL_FILES = $(RTL_DIR)/spi.sv
TB_FILES = $(TB_DIR)/spi_tb.sv

# Targets
help:
	@echo ================================================================================
	@echo " USAGE:"
	@echo "   make target                                   "
	@echo " TARGETS:"
	@echo "   clean      =>  Clean the earlier log and intermediate files."
	@echo "   run_sim    =>  Compile & run the simulation in batch mode."
	@echo "   run_test   =>  Clean, compile & run the simulation."
	@echo "   help       =>  Display this help message."
	@echo ================================================================================
	@echo

clean: clean_$(SIMULATOR)

run_sim: run_sim_$(SIMULATOR)

run_test: run_test_$(SIMULATOR)

# ---- QuestaSim Specific Targets ----
run_test_Questa: clean_Questa run_sim_Questa

run_sim_Questa:
	@echo "[INFO] Running simulation with QuestaSim..."
	@mkdir -p $(SIM_DIR)
	vlib $(SIM_DIR)/work
	vlog -work $(SIM_DIR)/work $(RTL_FILES) $(TB_FILES)
	vsim -c -do "run -all; quit" -work $(SIM_DIR)/work tb | tee $(SIM_DIR)/questa_output.log

clean_Questa:
	@echo "[INFO] Cleaning up simulation files for QuestaSim..."
	rm -rf $(SIM_DIR)/*
	clear

# ---- VCS Specific Targets ----
run_test_VCS: clean_VCS run_sim_VCS

run_sim_VCS:
	@echo "[INFO] Running simulation with VCS..."
	@mkdir -p $(SIM_DIR)
	vcs -l $(SIM_DIR)/vcs.log -sverilog $(RTL_FILES) $(TB_FILES) -o $(SIM_DIR)/simv
	$(SIM_DIR)/simv | tee $(SIM_DIR)/vcs_output.log

clean_VCS:
	@echo "[INFO] Cleaning up simulation files for VCS..."
	rm -rf $(SIM_DIR)/*
	clear

