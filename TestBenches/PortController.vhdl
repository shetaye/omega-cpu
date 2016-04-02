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
    CLK  : in std_logic;
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
  signal input_line_index_s : integer := -1;
  signal Done_s : std_logic := '0';
begin  -- PortController
  PortReady <= '1';
  Done <= Done_s;

  process (CPUReady)
    variable input_line : line;
    variable input_char : character;
    variable input_line_index : integer := -1; 
  begin  -- process
    if rising_edge(CPUReady) and GetOpcode(instruction) = OpcodePort then  -- rising clock edge
      case GetOperator(instruction) is    
        when LoadByteSigned|LoadHalfWordSigned|LoadByteUnsigned|LoadHalfWordUnsigned|LoadWord =>
         if CPUReady = '1' and getRegisterReferenceB(instruction) = "00001" then
           PortSending <= '1';
           input_line_index := input_line_index_s;
           if input_line_index = -1 then
             readline(input,input_line);
             input_line_index := 0;
           end if;
           read(input_line,input_char);
           Recv <= "000000000000000000000000" & std_logic_vector(to_unsigned(character'pos(input_char),8));
           if input_line_index + 1 >= input_line'length then
             input_line_index := -1;
           else
             input_line_index := input_line_index + 1;
           end if;
           input_line_index_s <= input_line_index;
           else
             PortSending <= '0';
         end if;
        when others => null;
      end case;
    end if;
  end process;
  
  process (CPUSending)
    variable c : integer;
    variable out_line : line;
  begin  -- process
    if rising_edge(CPUSending) then  -- rising clock edge
      case GetOperator(instruction) is
       when StoreByte|StoreHalfWord|StoreWord =>
         PortSending <= '0';
         if CPUSending = '1' and GetRegisterReferenceB(instruction) = "00001" then
           c := to_integer(unsigned(XMit(7 downto 0)));
           if c /= 10 then
             --write(out_line, to_bitvector(XMit));
             write(out_line, character'val(c));
           else
             writeline(output, out_line);
           end if;
           Done_s <= '1';
         else
           Done_s <= '0';
         end if;
       when others =>
         Done_s <= '0';
         PortSending <= '0';
      end case;
    else
      PortSending <= '0';
      Done_s <= '0';
    end if;
  end process;

end Behavioral;
