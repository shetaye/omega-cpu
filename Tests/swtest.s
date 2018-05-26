loop:
	ADDI $r1,$r0,67
	LA $r2,location
	SW $r1,$r2
	ADD $r1,$r0,$r0
	LW $r1,$r2
	OUTPB $r1,$p1
	ADD $r3,$r0,$r0
timeDelay:
	ADDI $r3,$r3,1
	EQI $r4,$r3,1000
	BZI $r4,timeDelay
	J loop
location: .byte 0,0,0,0