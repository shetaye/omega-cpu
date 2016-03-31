-- This file is part of the Omega CPU Core
-- Copyright 2015 - 2016 Joseph Shetaye

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library IEEE;
use IEEE.std_logic_1164.all;
use work.Constants.all;
use IEEE.Numeric_std.all;
use std.textio.all;

entity Memory_TB is
  
end Memory_TB;

architecture Behavioral of Memory_TB is

  
component MemoryController
  port (
    Address     : in  word;
    Enable      : in  std_logic;
    ToWrite     : in  word;
    FromRead    : out word;
    Instruction : in  word;
    Reset       : in  std_logic;
    Done        : out std_logic);
end component;

signal Address : word := (others => '0');
signal Enable : std_logic := '0';
signal ToWrite : word := (others => '0');
signal FromRead : word;
signal Instruction : word := (others => '0');



begin  -- Behavioral

MC : MemoryController port map (
  Address => Address,
  Enable => Enable,
  ToWrite => ToWrite,
  FromRead => FromRead,
  Instruction => Instruction,
  Reset => '0');

   file_io:
    process is
      variable in_line : line;
      variable out_line : line;
      variable in_vector : bit_vector(7 downto 0) := (others => '0');
      variable outputI : integer := 0;
      variable Counter : integer := 0;
      variable NextByte : Byte := (others => '0');
      
    begin  -- process
  while not endfile(input) loop
    readline(input, in_line);
    if in_line'length = 8 then
     read(in_line, in_vector);
       NextByte := to_stdlogicvector(in_vector);
       ToWrite <= std_logic_vector(resize(unsigned(NextByte), 32));
       Instruction <= OpcodeMemory & StoreByte & "00000" & "000000000000000000000";
       Address <= std_logic_vector(to_unsigned(Counter, 32));
     wait for 1 ns;
       Enable <= '1';
       wait for 1 ns;
       Enable <= '0';
       Counter := Counter + 1;
    else
      writeline(output,in_line);
    end if;
  end loop;
--write(out_line, string'("===============ByteRead================"));
--      write(output, out_line);
  for i in 0 to Counter loop
    Instruction <= OpcodeMemory & LoadByteUnsigned & "00000" & "000000000000000000000";

    Address <= std_logic_vector(to_unsigned(i, 32));

    wait for 1 ns;

    write(out_line, to_integer(unsigned(Address)));
       writeline(output, out_line);
    Enable <= '1';

    wait for 1 ns;

    Enable <= '0';

    NextByte := FromRead(7 downto 0);

    write(out_line, to_bitvector(NextByte));
       writeline(output, out_line);
  end loop;  -- i
 for I in 0 to Counter / 2 loop

   Instruction <= OpcodeMemory & LoadHalfWordUnsigned & "00000" & "000000000000000000000";

    Address <= std_logic_vector(to_unsigned(i*2, 32));

    wait for 1 ns;

    write(out_line, to_integer(unsigned(Address)));
       writeline(output, out_line);
    Enable <= '1';

    wait for 1 ns;

    Enable <= '0';

    write(out_line, to_bitvector(FromRead(15 downto 0)));
       writeline(output, out_line);
   
 end loop;  -- I

for I in 0 to Counter / 4 loop
  Instruction <= OpcodeMemory & LoadWord & "00000" & "000000000000000000000";

    Address <= std_logic_vector(to_unsigned(i*4, 32));

    wait for 1 ns;

    write(out_line, to_integer(unsigned(Address)));
       writeline(output, out_line);
    Enable <= '1';

    wait for 1 ns;

    Enable <= '0';

    write(out_line, to_bitvector(FromRead(31 downto 0)));
       writeline(output, out_line);
   
end loop;  -- I
  wait;
    end process;

end Behavioral;
