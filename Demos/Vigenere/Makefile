OMEGA_ROOT=../..
PYTHON=python
ASSEMBLER=$(OMEGA_ROOT)/Assembler/OmegaAssembler.py
LIB_DIR=$(OMEGA_ROOT)/lib

all: vigenere.bin

vigenere.bin: $(LIB_DIR)/runtime.s $(LIB_DIR)/print_string.s vigenere.s
	$(PYTHON) $(ASSEMBLER) $^ > $@

clean:
	rm -fv *.bin

