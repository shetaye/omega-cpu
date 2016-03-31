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
use std.textio.all;
use work.Constants.all;
use IEEE.Numeric_std.all;

entity PortController is

  port (
    XMit : in Word;
    Recv : out Word;
    instruction : in Word;
    CPUReady : in std_logic;
    CPUSending: in std_logic;
    PortReady: out std_logic;
    PortSending: out std_logic;
    Done: out std_logic);
  
end PortController;
architecture Behavioral of PortController is

begin  -- PortController

  PortReady <= '1';
  PortSending <= '0';
  
  process (CPUReady, CPUSending)
    variable c : integer;
    variable input_line : line;
    variable input_char : character;
    variable input_line_index : integer := -1; 
    variable out_line : line;
  begin  -- process
    if rising_edge(CPUSending) then  -- rising clock edge
      case GetOperator(instruction) is 
       when StoreByte|StoreHalfWord|StoreWord =>
         if CPUSending = '1' and GetRegisterReferenceB(instruction) = "00001" then
           c := to_integer(unsigned(XMit(7 downto 0)));
           if c /= 10 then
             --write(out_line, to_bitvector(XMit));
             write(out_line, character'val(c));
           else
             writeline(output, out_line);
           end if;
           Done <= '1';
         else
           Done <= '0';
         end if;
        when LoadByteSigned|LoadHalfWordSigned|LoadByteUnsigned|LoadHalfWordUnsigned|LoadWord =>
         if CPUReady = '1' and getRegisterReferenceB(instruction) = "00001" then
           if input_line_index = -1 then
             readline(input,input_line);
             input_line_index := 0;
           end if;
           read(input_line,input_char);
           Recv <= std_logic_vector(to_unsigned(character'pos(input_char),8));
           if input_line_index + 1 >= input_line'length then
             input_line_index := -1;
           else
             input_line_index := input_line_index + 1;
           end if;
         end if;
       when others => Done <= '0';
      end case;
    else
      Done <= '0';
    end if;
  end process;

end Behavioral;
