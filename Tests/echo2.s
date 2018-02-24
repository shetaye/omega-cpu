.text
ADDI $r2,$r0,64
Loop:
ADDI $r2,$r2,1
SUBI $r3,$r2,91
BZI $r3,CapReached
Readout:
Timeout:
ADDI $r4,$r4,1
SUBI $r5,$r4,50000
BNZI $r5,Timeout
OUTPB $r2,$p1
J Loop
CapReached:
ADDI $r2,$r0,64
J Readout
