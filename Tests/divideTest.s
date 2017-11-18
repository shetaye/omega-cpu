.text
	ADDI $r27,$r0,4000
	J byteloop

byteloop:
  INPB $r4,$p1
  INPB $r5,$p1
  DIV $r4,$r4,$r5,$r5
  OUTPB $p1,$r4
  OUTPB $p1,$r5
  J byteloop
