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

entity BranchUnitTB is

end BranchUnitTB;

architecture Behaivoral of BranchUnitTB is
component  BranchUnit is

  port (
    Instruction : in Word;
    RegisterA : in Word;
    RegisterB : in Word;
    NewPC : out Word;
    CurrentPC : in Word;
    OutputReady : out std_logic);
end component BranchUnit;
    signal Instruction :  Word;
    signal RegisterA :  Word;
    signal RegisterB :  Word;
    signal NewPC :  Word;
    signal CurrentPC :  Word;
    signal OutputReady : std_logic;
begin  -- Behaivoral
  
  UUT: entity work.BranchUnit port map (
   Instruction => Instruction,
   RegisterA => RegisterA,
   RegisterB => RegisterB,
   NewPC => NewPC,
   CurrentPC => CurrentPC,
   OutputReady => OutputReady);

   file_io:
    process is
      variable in_line : line;
      variable out_line : line;
      variable in_vector : bit_vector(31 downto 0) := (others => '0');
      variable outputI : integer := 0;
      variable Counter : integer := 0;
      variable ExpectedNewPC : Word := (others => '0');
    begin  -- process
  while not endfile(input) loop
    readline(input, in_line);
    if in_line'length = 32 then
     read(in_line, in_vector);
      case Counter is
        when 0 =>
       RegisterA <= to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 1 =>
       RegisterB <= to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 2 =>
       Instruction <= to_stdlogicvector(in_vector);
       Counter := Counter + 1;
       when 3 =>
       CurrentPC <= to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 4 =>
       ExpectedNewPC := to_stdlogicvector(in_vector);
       wait for 1 ns;
       write(out_line, to_bitvector(NewPC));
       writeline(output, out_line);
       if (NewPC = ExpectedNewPC) then
         write(out_line, string'("Passed"));
        else
         write(out_line, string'("Failed"));
       end if;
       writeline(output, out_line);
       Counter := 0;
       when others => null;
      end case;
    else
      writeline(output,in_line);
    end if;
  end loop;
  wait;
    end process;

end Behaivoral;
