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

test1: .asciiz "123"
test2: .asciiz "-2"
test3: .asciiz "-2147483648"
test4: .asciiz "abc"
test5: .asciiz "123a"
.text
main:
	ADDI $r12,$r0,10
	LA $r4,test1
	ADDI $r13,$r0,0
	CALL read_int
	ADDI $r13,$r3,0
	ADDI $r4,$r2,0
	CALL print_int
	OUTPB $r12,$p1
	ADDI $r4,$r13,0
	CALL print_int
	OUTPB $r12,$p1
	LA $r4,test2
	CALL read_int
	ADDI $r4,$r2,0
	ADDI $r13,$r3,0
	CALL print_int
	OUTPB $r12,$p1
	ADDI $r4,$r13,0
	CALL print_int
	OUTPB $r12,$p1
	LA $r4,test3
	CALL read_int
	ADDI $r4,$r2,0
	ADDI $r13,$r3,0
	CALL print_int
	OUTPB $r12,$p1
	ADDI $r4,$r6,0
	CALL print_int
	OUTPB $r12,$p1
	LA $r4,test4
	CALL read_int
	ADDI $r4,$r2,0
	ADDI $r13,$r3,0
	CALL print_int
	OUTPB $r12,$p1
	ADDI $r4,$r13,0
	CALL print_int
	OUTPB $r12,$p1
	LA $r4,test5
	CALL read_int
	ADDI $r4,$r2,0
	ADDI $r13,$r3,0
	CALL print_int
	OUTPB $r12,$p1
	ADDI $r4,$r13,0
	CALL print_int
	OUTPB $r12,$p1
end:
	J end
