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
#; along with this program.  If not, see <http://www.gnu.org/licenses/>
.text
read_int:
	ADDI $r2,$r0,0
	ADDI $r8,$r0,0
	SUBI $r4,$r4,1
state1:
	ADDI $r4,$r4,1
	LB $r9,$r4
	EQI $r10,$r9,48
	BNZI $r10,state3
	EQI $r10,$r9,45
	BNZI $r10,state2
	ADDI $r11,$r0,48
	LT $r11,$r11,$r9
	LTI $r10,$r9,58
	AND $r10,$r10,$r11
	BNZI $r10,addDigit
	J state0
state2:
	ADDI $r4,$r4,1
	LB $r9,$r4
	ADDI $r8,$r0,1
	EQI $r10,$r9,48
	BNZI $r10,state3
	ADDI $r11,$r0,48
	LT $r11,$r11,$r9
	LTI $r10,$r9,58
	AND $r10,$r10,$r11
	BNZI $r10,addDigit
	J state0
state3:
	ADDI $r4,$r4,1
	LB $r9,$r4
	EQ $r10,$r9,$r5
	BZI $r10,state0
	ADDI $r3,$r0,1
	RET
state4:
	ADDI $r4,$r4,1
	LB $r9,$r4
	EQ $r10,$r9,$r5
	BZI $r10,notTerminator
	ADDI $r3,$r0,1
	RET
notTerminator:
	ADDI $r11,$r0,47
	LT $r11,$r11,$r9
	LTI $r10,$r9,58
	AND $r10,$r10,$r11
	BZI $r10,notDigit
addDigit:
	MULTI $r2,$r2,10
	SUBI $r9,$r9,48
	BZI $r8,NonNegative
	MULTI $r9,$r9,-1
NonNegative:
	ADD $r2,$r2,$r9
	J state4
notDigit:
	J state0
state0:
	ADDI $r2,$r0,-1
	RET
