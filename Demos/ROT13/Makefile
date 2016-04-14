OMEGA_ROOT=../..
PYTHON=python
ASSEMBLER=$(OMEGA_ROOT)/Assembler/OmegaAssembler.py

all: rot13.bin

rot13.bin: rot13.s
	$(PYTHON) $(ASSEMBLER) $^ > $@

clean:
	rm -fv *.bin
