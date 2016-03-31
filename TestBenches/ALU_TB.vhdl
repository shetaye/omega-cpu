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

entity ALU_TB is
  
end ALU_TB;

architecture Behavioral of ALU_TB is
component ALU
   port (
    RegisterB   : in  Word;
    RegisterC   : in  Word;
    Instruction : in  Word;
    RegisterA   : out Word;
    RegisterD   : out Word;
    Carry       : out std_logic;
    OutputReady : out std_logic);
end component;

   signal RegisterB   :  Word;
   signal RegisterC   :  Word;
   signal Instruction :  Word;
   signal RegisterA   :  Word;
   signal RegisterD   :  Word;
   signal Carry : std_logic;
   signal OutputReady :  std_logic;

begin  -- Behavioral

  UUT : entity work.ALU port map (
    RegisterB => RegisterB,
    RegisterC => RegisterC,
    Instruction => Instruction,
    RegisterA => RegisterA,
    RegisterD => RegisterD,
    Carry   => Carry,
    OutputReady => OutputReady);

  file_io:
    process is
      variable in_line : line;
      variable out_line : line;
      variable in_vector : bit_vector(31 downto 0) := (others => '0');
      variable outputI : integer := 0;
      variable Counter : integer := 0;
      variable ExpectedCarry : std_logic := '0';
      variable ExpectedRegisterA : Word := (others => '0');
      variable ExpectedRegisterD : Word := (others => '0');
    begin  -- process
  while not endfile(input) loop
    readline(input, in_line);
    if in_line'length = 32 then
     read(in_line, in_vector);
      case Counter is
        when 0 =>
       RegisterB <= to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 1 =>
       RegisterC <= to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 2 =>
       Instruction <= to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 3 =>
       ExpectedRegisterD := to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 4 =>
       ExpectedRegisterA := to_stdlogicvector(in_vector);
       Counter := Counter + 1;
        when 5 =>
       ExpectedCarry := to_stdlogicvector(in_vector)(0);
       wait for 1 ns;
       write(out_line, to_bitvector(RegisterD));
       writeline(output, out_line);
       write(out_line, to_bitvector(RegisterA));
       writeline(output, out_line);
       write(out_line, to_bit(Carry));
       writeline(output, out_line);
       if (RegisterD = ExpectedRegisterD) and (RegisterA = ExpectedRegisterA) and (Carry = ExpectedCarry) then
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
end Behavioral;

