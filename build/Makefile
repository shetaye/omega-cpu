CC=gcc
GHDL=ghdl
CFLAGS=
GHDLAFLAGS=
GHDLEFLAGS=
BASE_DIR=..

CORE_DIR=$(BASE_DIR)/Core
TB_DIR=$(BASE_DIR)/TestBenches
LIB_DIR=$(BASE_DIR)/lib


CORE_FILES=$(CORE_DIR)/Constants.vhdl $(CORE_DIR)/ALU.vhdl $(CORE_DIR)/BranchUnit.vhdl $(CORE_DIR)/Control.vhdl
TB_MOCKUP_FILES=$(TB_DIR)/MemoryController.vhdl $(TB_DIR)/PortController.vhdl
GHDL_ENV_FILES=$(TB_DIR)/ghdl_env.vhdl

all: cpu_tb

clean:
	rm -fv *.o cpu_tb work-obj93.cf

ghdl_env_c.o: $(TB_DIR)/ghdl_env_c.c
	$(CC) -c $(CFLAGS) -o ghdl_env_c.o $(TB_DIR)/ghdl_env_c.c

AnalyzeCoreFiles: $(CORE_FILES)
	$(GHDL) -a $(GHDLAFLAGS) $(CORE_FILES)

AnalyzeTestBenchMockups: $(TB_MOCKUP_FILES)
	$(GHDL) -a $(GHDLAFLAGS) $(TB_MOCKUP_FILES)

AnalyzeEnvInterface: $(GHDL_ENV_FILES) ghdl_env_c.o
	$(GHDL) -a $(GHDLAFLAGS) $(GHDL_ENV_FILES)

cpu_tb: AnalyzeCoreFiles AnalyzeTestBenchMockups AnalyzeEnvInterface $(GHDL_ENV_FILE) $(TB_DIR)/CPU_TB.vhdl
	$(GHDL) -a $(GHDLAFLAGS) $(TB_DIR)/CPU_TB.vhdl
	$(GHDL) -e -Wl,ghdl_env_c.o $(GHDLEFLAGS) CPU_TB
