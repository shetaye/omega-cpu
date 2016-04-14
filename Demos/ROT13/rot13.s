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
byteIn:
	INPB $r4,$p1
	LTI $r1,$r4,65
	BNZI $r1,nonLetter
	LTI $r1,$r4,91
	BNZI $r1,uppercase
	LTI $r1,$r4,97
	BNZI $r1,nonLetter
	LTI $r1,$r4,123
	BNZI $r1,lowercase
	J nonLetter
out:	
	OUTPB $r4,$p1
	J byteIn

nonLetter:
	J out
uppercase:
	SUBI $r4,$r4,65
	ADDI $r4,$r4,13
	ADDI $r15,$r0,26
	DIV $r0,$r4,$r15,$r4
	ADDI $r4,$r4,65
	J out
lowercase:
	SUBI $r4,$r4,97
	ADDI $r4,$r4,13
	ADDI $r15,$r0,26
	DIV $r0,$r4,$r15,$r4
	ADDI $r4,$r4,97
	J out
