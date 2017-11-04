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

entity ALUControl is

  port (
    RegisterB   : in  Word;
    RegisterC   : in  Word;
    Instruction : in  Word;
    RegisterA   : out Word;
    RegisterD   : out Word;
    Carry       : out std_logic;
    OutputReady : out std_logic;
    Status : out std_logic_vector(1 downto 0));

end ALUControl;

architecture Behavioral of ALUControl is
  component ALU is

    port (
      RegisterB_A   : in  Word;
      RegisterC_A   : in  Word;
      Instruction_A : in  Word;
      RegisterA_A   : out Word;
      RegisterD_A   : out Word;
      Carry_A       : out std_logic;
      OutputReady_A : out std_logic;
      Status_A : out std_logic_vector(1 downto 0));

  end component ALU;
  component Divider_sequential is
    port (
      Enable_D    : in  std_logic;
      Ready_D     : out std_logic;
      CLK_D       : in  std_logic;
      Overflow_D  : out std_logic;
      Divisor_D   : in  std_logic_vector(31 downto 0);
      Dividend_D  : in  std_logic_vector(31 downto 0);
      Remainder_D : out std_logic_vector(31 downto 0);
      Quotient_D  : out std_logic_vector(31 downto 0);
      IsSigned_D  : in  std_logic);

  end component Divider_sequential;
  signal RegisterA_S   : Word;
  signal RegisterB_S   : Word;
  signal RegisterC_S   : Word;
  signal RegisterD_S   : Word;
  signal Enable_S      : std_logic;
  signal Status_S      : std_logic_vector(1 downto 0);
  signal Ready_S       : std_logic;
  signal Carry_S       : std_logic;
  signal Instruction_S : Word;
  begin
end Behavioral
