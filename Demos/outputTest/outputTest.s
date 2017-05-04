.text
	ADDI $r1,$r0,65
loop:
	OUTPB $r1,$p1
	J loop
#JA loop
