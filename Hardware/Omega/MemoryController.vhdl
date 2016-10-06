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
use work.constants.all;
use IEEE.Numeric_std.all;

entity MemoryController is

  port (
    CLK         : in  std_logic;
    Address     : in  word;
    Enable      : in  std_logic;
    ToWrite     : in  word;
    FromRead    : out word;
    Instruction : in  word;
    Reset       : in  std_logic;
    Done        : out std_logic);
  
end MemoryController;

architecture Behavioral of MemoryController is

 constant LoadByteUnsigned : Operator := "000";
 constant LoadByteSigned : Operator := "001";
 constant LoadHalfWordUnsigned : Operator := "010";
 constant LoadHalfWordSigned : Operator := "011";
 constant LoadWord : Operator := "100";
 constant StoreByte : Operator := "101";
 constant StoreHalfWord : Operator := "110";
 constant StoreWord : Operator := "111";
 
 signal Memory : MemoryArray := (others => (others => '0'));
 signal FromRead_S : Word := (others => '0');
 
begin  -- Behavioral

  FromRead <= FromRead_S;
  
  process (CLK)--(Enable, Instruction, Address, Reset)
     procedure initialize is begin
		Memory(0) <= "01000001";
		Memory(1) <= "00000000";
		Memory(2) <= "00100000";
		Memory(3) <= "00100100";
		Memory(4) <= "00000000";
		Memory(5) <= "00000000";
		Memory(6) <= "00100001";
		Memory(7) <= "10110100";
		Memory(8) <= "11111111";
		Memory(9) <= "11111111";
		Memory(10) <= "11111111";
		Memory(11) <= "11001011";
      --for I in 100 to 4095 loop
		--	Memory(I) <= "00000000";
		--end loop;
     end procedure initialize;
	  variable current_operator : std_logic_vector(2 downto 0);
  begin  -- process
  if rising_edge(CLK) then
    if Reset = '1' then
      --Memory <= (others => (others => '0'));
		initialize;
    elsif Enable = '1' then
	 current_operator := GetOperator(Instruction);
    case current_operator is
      when LoadByteUnsigned =>
        FromRead_S <= "000000000000000000000000" & Memory(to_integer(unsigned(Address)));
       Done <= '1';
      when LoadByteSigned =>
        FromRead_S <= std_logic_vector(resize(signed(Memory(to_integer(unsigned(Address)))), 32));
         Done <= '1';
      when LoadHalfWordUnsigned =>
        FromRead_S <= "0000000000000000" & Memory(to_integer(unsigned(Address)) + 1) & Memory(to_integer(unsigned(Address)));
         Done <= '1';
      when LoadHalfWordSigned =>
       FromRead_S <= std_logic_vector(
                     resize(
                       signed(
                         Memory(
                           to_integer(
                             unsigned(Address)
                           )
                           + 1
                         )
                       ) &
                       signed(
                         Memory(
                           to_integer(
                             unsigned(Address)
                           )
                         )
                       ),
                       32
                     )
                   );
        Done <= '1';
      when LoadWord =>
        FromRead_S <=  Memory(to_integer(unsigned(Address)) + 3) & Memory(to_integer(unsigned(Address)) + 2) & Memory(to_integer(unsigned(Address)) + 1) & Memory(to_integer(unsigned(Address)));
         Done <= '1';
      when StoreByte =>
        Memory(to_integer(unsigned(Address))) <= ToWrite(7 downto 0);
         Done <= '1';
      when StoreHalfWord =>
        Memory(to_integer(unsigned(Address))) <= ToWrite(7 downto 0);
        Memory(to_integer(unsigned(Address)) + 1) <= ToWrite(15 downto 8);
         Done <= '1';
      when StoreWord =>
        Memory(to_integer(unsigned(Address))) <= ToWrite(7 downto 0);
        Memory(to_integer(unsigned(Address)) + 1) <= ToWrite(15 downto 8);
        Memory(to_integer(unsigned(Address)) + 2) <= ToWrite(23 downto 16);
        Memory(to_integer(unsigned(Address)) + 3) <= ToWrite(31 downto 24);
         Done <= '1';
      when others => null;
    end case;
  else
    Done <= '0';
  end if;
  end if;
  end process;

end Behavioral;
