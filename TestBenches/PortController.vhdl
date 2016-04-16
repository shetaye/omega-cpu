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
    Done: out std_logic;
    SerialIn: in std_logic;
    SerialOut: out std_logic);
  
end PortController;
architecture Behavioral of PortController is
  signal Done_s : std_logic := '0';
  signal PortSending_s : std_logic := '0';
  signal nextWord : Word := (others => '0');
  --signal readControl : integer := 0;
begin  -- PortController
  SerialOut <= '0';
  PortSending <= PortSending_s;
  Recv <= nextWord when PortSending_s = '1' else (others => '0');
  Done <= Done_s;
    
  process
    variable input_line : line;
    variable input_char : character;
    variable input_read : boolean := false; 
  begin  -- process
    PortReady <= '0';
    PortSending_s <= '0';
    wait until rising_edge(CPUReady) and GetOpcode(instruction) = OpcodePort and (GetOperator(instruction) = LoadByteSigned or GetOperator(instruction) = LoadHalfWordSigned or GetOperator(instruction) = LoadByteUnsigned or GetOperator(instruction) = LoadHalfWordUnsigned or GetOperator(instruction) = LoadWord) and getRegisterReferenceB(instruction) = "00001";  -- rising clock edge
    --wait until readControl = 1;
     if not input_read then
       readline(input,input_line);
     end if;
    if input_line'length > 0 then
      read(input_line,input_char);
     nextWord <= "000000000000000000000000" & std_logic_vector(to_unsigned(character'pos(input_char),8));
      input_read := true;
    else
      nextWord <= "00000000000000000000000000001010";
        input_read := false;
     end if;
    PortReady <= '1';
    PortSending_s <= '1';
    wait until CPUReady = '0';
  end process;
  
  process (CPUSending)
    variable c : integer;
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
           Done_s <= '1';
         else
           Done_s <= '0';
         end if;
       when others =>
         Done_s <= '0';
      end case;
    else
      Done_s <= '0';
    end if;
  end process;

end Behavioral;
