#; This file is part of the Omega CPU Core
#; Copyright 2015 - 2016 Joseph Shetaye

#; This program is free software: you can redistribute it and/or modify
#; it under the terms of the GNU Lesser General Public License as
#; published by the Free Software Foundation, either version 3 of the
#; License, or (at your option) any later version.

#; This program is distributed in the hope that it will be useful,
#; but WITHOUT ANY WARRANTY; without even the implied warranty of
#; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#; GNU General Public License for more details.

#; You should have received a copy of the GNU General Public License
#; along with this program.  If not, see <http://www.gnu.org/licenses/>.
.text
	ADDI $r27,$r0,4000
	J main

print_int:
	ADDI $r9,$r27,0
	ADDI $r8,$r0,10
	LTI $r1,$r4,0
	ADDI $r1,$r0,45
	OUTPB $r1,$p1
	BZI $r1,positive
	XORI $r4,$r4,-1
	ADDI $r4,$r0,1
positive:
	BNZI $r4,nonZero
	ADDI $r1,$r0,48
	OUTPB $r1,$p1
	RET
nonZero:
	BZI $r4,endOfNonZero
	DIV $r2,$r4,$r8,$r3
	ADDI $r3,$r3,48
	SW $r3,$r27
	SUBI $r27,$r27,4
	J endOfNonZero
endOfNonZero:
	ADDI $r27,$r27,4
	EQ $r1,$r27,$r9
	LW $r3,$r27
	OUTPB $r3,$p1
	BNZI $r1,endOfNonZero
	ADDI $r2,$r0,0
	ADDI $r3,$r0,0
	RET

main:
	ADDI $r4,$r0,25
	CALL print_int
	OUTPB $r8,$p1
	ADDI $r4,$r0,-23
	CALL print_int
	OUTPB $r8,$p1
	ADDI $r4,$r0,0
	CALL print_int
	OUTPB $r8,$p1
main_end:
	J main_end
