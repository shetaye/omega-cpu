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
LA $r1,Byte
LA $r3,Hello
Loop:
LB $r2,$r3
BZI $r2,EndLoop
OUTPB $r2,$p1
ADDI $r3,$r3,1
J Loop
EndLoop:
J EndLoop
.data
Hello: .asciiz "Hello World\n"
Byte: .byte 101
