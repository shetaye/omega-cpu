.text
ADDI $r2,$r0,64
Loop:
ADDI $r2,$r2,1
SUBI $r3,$r2,91
BZI $r3,CapReached
Readout:
OUTPB $r2,$p1
J Loop
CapReached:
ADDI $r2,$r0,64
J Readout
