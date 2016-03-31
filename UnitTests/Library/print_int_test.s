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
main:
	ADDI $r4,$r0,1
	SLL $r4,$r4,31
	CALL print_int
	OUTPB $r8,$p1
	ADDI $r4,$r0,32767
	SLL $r4,$r4,16
	ORI $r4,$r4,65535
	CALL print_int
	OUTPB $r8,$p1
	ADDI $r4,$r0,-4
	CALL print_int
	OUTPB $r8,$p1
main_end:
	J main_end
