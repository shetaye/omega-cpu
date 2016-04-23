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

entity BranchUnit is

  port (
    Instruction : in Word;
    RegisterA : in Word;
    RegisterB : in Word;
    NewPC : out Word;
    CurrentPC : in Word;
    OutputReady : out std_logic);

  
  
end BranchUnit;

architecture Behavioral of BranchUnit is
  
constant UnconditionalAbsoluteR : std_logic_vector(2 downto 0) := "000";
constant UnconditionalAbsoluteI : std_logic_vector(2 downto 0) := "001";
constant UnconditionalRelativeI : std_logic_vector(2 downto 0) := "010";
constant On0AbsoluteR : std_logic_vector(2 downto 0) := "011";
constant On0RelativeI : std_logic_vector(2 downto 0) := "100";
constant OnNot0AbsoluteR : std_logic_vector(2 downto 0) := "101";
constant OnNot0RelativeI : std_logic_vector(2 downto 0) := "110";

  signal Opcode_S : Opcode;
  signal Operator_S : Operator;
  signal RegisterReferenceA : RegisterReference;
  signal RegisterReferenceB : RegisterReference;
  signal ImmediateAddress_S : ImmediateAddress;
  signal ImmediateConditionalAddress_S : ImmediateConditionalAddress;
  
begin  -- Behavioral

  Opcode_S <= GetOpcode(Instruction);
  Operator_S <= GetOperator(Instruction);
  RegisterReferenceA <= GetRegisterReferenceA(Instruction);
  RegisterReferenceB <= GetRegisterReferenceB(Instruction);
  ImmediateAddress_S <= GetImmediateAddress(Instruction);
  ImmediateConditionalAddress_S <= GetImmediateConditionalAddress(Instruction);

  Branch: process (Opcode_S, Operator_S, RegisterReferenceA, RegisterReferenceB, ImmediateAddress_S, RegisterA, RegisterB, CurrentPC, ImmediateConditionalAddress_s)
  begin  -- process
    if Opcode_S = OpcodeBranch then
      case Operator_S is
        when UnconditionalAbsoluteR =>
          NewPC <= RegisterB;
          OutputReady <= '1';
        when UnconditionalAbsoluteI =>
          NewPC <= "0000" & ImmediateAddress_S & "00";
          OutputReady <= '1';
        when UnconditionalRelativeI => 
          NewPC <= std_logic_vector(unsigned(CurrentPC) - 4 + unsigned(SignExtendImmediateAddress(ImmediateAddress_S)));
          OutputReady <= '1';
        when On0AbsoluteR =>
          if RegisterA = "00000000000000000000000000000000" then
            NewPC <= RegisterB;
            OutputReady <= '1';
          else
            NewPC <= CurrentPC;
            OutputReady <= '1';
          end if;
        when On0RelativeI =>
            if RegisterA = "00000000000000000000000000000000" then
            NewPC <= std_logic_vector(unsigned(CurrentPC) - 4 + unsigned(SignExtendImmediateConditionalAddress(ImmediateConditionalAddress_S)));
            OutputReady <= '1';
          else
            NewPC <= CurrentPC;
            OutputReady <= '1';
          end if;
        when OnNot0AbsoluteR =>
             if RegisterA /= "00000000000000000000000000000000" then
            NewPC <= RegisterB;
            OutputReady <= '1';
          else
            NewPC <= CurrentPC;
            OutputReady <= '1';
          end if;
        when OnNot0RelativeI =>
            if RegisterA /= "00000000000000000000000000000000" then
            NewPC <= std_logic_vector(unsigned(CurrentPC) - 4 + unsigned(SignExtendImmediateConditionalAddress(ImmediateConditionalAddress_S)));
            OutputReady <= '1';
          else
            NewPC <= CurrentPC;
            OutputReady <= '1';
          end if;
        when others  =>
            NewPC <= CurrentPC;
            OutputReady <= '1';
      end case;
    end if;
  end process;
  
end Behavioral;
