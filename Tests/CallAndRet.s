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

Call:	
	SW $r28,$r27
	ADDI $r28,$r27,0
	SUBI $r27,$r27,4
	SW $r29,$r27
	SUBI $r27,$r27,4
	ADDI $r29,$r31,4
	J label
	SUBI $r27,$r28,4
	LW $r29,$r27
	ADDI $r27,$r27,4
	LW $r28,$r27

Ret:
	JR $r29
	