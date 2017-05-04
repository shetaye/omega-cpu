OMEGA_ROOT=../..
PYTHON=python
ASSEMBLER=$(OMEGA_ROOT)/Assembler/OmegaAssembler.py

all: outputTest.bin

outputTest.bin: outputTest.s
	$(PYTHON) $(ASSEMBLER) $^ > $@

clean:
	rm -fv *.bin
