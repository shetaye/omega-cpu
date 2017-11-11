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
    CLK         : in std_logic;
    Enable      : in std_logic;
    RegisterB   : in  Word;
    RegisterC   : in  Word;
    Instruction : in  Word;
    RegisterA   : out Word;
    RegisterD   : out Word;
    Carry       : out std_logic;
    OutputReady : out std_logic;
    Status : out std_logic_vector(1 downto 0));

  type machine_state is (State_Start,State_ALU,State_Divide);

end ALUControl;

architecture Behavioral of ALUControl is
  component ALU is

    port (
      RegisterB   : in  Word;
      RegisterC   : in  Word;
      Instruction : in  Word;
      RegisterA   : out Word;
      RegisterD   : out Word;
      Carry       : out std_logic;
      OutputReady : out std_logic;
      Status : out std_logic_vector(1 downto 0));

  end component ALU;
  component DividerSequential is
    port (
      Enable    : in  std_logic;
      Ready     : out std_logic;
      CLK       : in  std_logic;
      Overflow  : out std_logic;
      Instruction : in  Word;
      Divisor   : in  Word;
      Dividend  : in  Word;
      Remainder : out Word;
      Quotient  : out Word;
      IsSigned  : in  std_logic);

  end component DividerSequential;
  signal RegisterA_S   : Word := (others => '0');
  signal RegisterB_S   : Word := (others => '0');
  signal RegisterC_S   : Word := (others => '0');
  signal RegisterD_S   : Word := (others => '0');
  signal Enable_S      : std_logic := '0';
  signal Status_S      : std_logic_vector(1 downto 0) := "00";
  signal Ready_S       : std_logic := '0';
  signal Carry_S       : std_logic := '0';
  signal Instruction_S : Word := (others => '0');
  signal state : machine_state := State_Start;
  signal isSigned_S : std_logic := '0';
  signal RegisterD_SA : Word := (others => '0');
  signal RegisterA_SA : Word := (others => '0');
  signal OutputReady_SA : std_logic := '0';
  signal RegisterA_SD : Word := (others => '0');
  signal RegisterD_SD : Word := (others => '0');
  signal Carry_SD : std_logic := '0';
  signal OutputReady_SD : std_logic := '0';
  signal Enable_SD : std_logic := '0';
  signal Carry_SA : std_logic := '0';
  signal Status_SA : std_logic_vector(1 downto 0) := "00";
  begin
    alu_i : ALU port map (
      RegisterB => RegisterB_S,
      RegisterC => RegisterC_S,
      RegisterD => RegisterD_SA,
      RegisterA => RegisterA_SA,
      Carry => Carry_SA,
      OutputReady => OutputReady_SA,
      Status => Status_SA,
      Instruction => Instruction_S
      );
    divider_unit : DividerSequential port map (
      CLK => CLK,
      Dividend => RegisterB_S,
      Divisor => RegisterC_S,
      IsSigned => isSigned_S,
      Quotient => RegisterA_SD,
      Remainder => RegisterD_SD,
      Instruction => Instruction_S,
      Overflow => Carry_SD,
      Ready => OutputReady_SD,
      Enable => Enable_SD
      );

    RegisterD <= RegisterD_S;
    RegisterA <= RegisterA_S;
    Carry <= Carry_S;
    OutputReady <= Ready_S;
    Status <= Status_S;
    
    RegisterB_S <= RegisterB;
    
    Instruction_S <= Instruction;
    isSigned_S <= not Instruction(0);
    control: process(CLK)
      variable SignExtendedImmediate : std_logic_vector(31 downto 0);
      variable Operator_V : std_logic_vector(2 downto 0) := "000";
      begin
        if rising_edge(CLK) then
          Operator_V := GetOperator(Instruction_S);
          SignExtendedImmediate := std_logic_vector(resize(signed(GetImmediateValue(Instruction_S)), 32));
          case state is
            when State_Start =>
              Ready_S <= '0';
              if Enable = '1' then
                if GetOpcode(Instruction_S)= OpcodeArithmetic and (Operator_V(2 downto 1) = OperatorDivide) then
                  if Operator_V(0)=RegisterMode then
                    RegisterC_S <= RegisterC;
                    state <= State_Divide;
                    Enable_SD <= '1';
                  elsif Operator_V(0)=ImmediateMode then
                    RegisterC_S <= SignExtendedImmediate;
                    state <= State_Divide;
                    Enable_SD <= '1';
                  end if;
                else
                  state <= State_ALU;
                  RegisterC_S <= RegisterC;
                end if;
              end if;
            when State_ALU =>
              if outputReady_SA='1' then
                Ready_S <= '1';
                RegisterD_S <= RegisterD_SA;
                RegisterA_S <= RegisterA_SA;
                Carry_S <= Carry_SA;
                Status_S <= Status_SA;
                state <= State_Start;
              end if;
            when State_Divide =>
              if outputReady_SD='1' then
                Ready_S <= '1';
                RegisterD_S <= RegisterD_SD;
                RegisterA_S <= RegisterA_SD;
                Enable_SD <= '0';
                Carry_S <= '0';
                if Carry_SD = '1' then
                  Status_S <= DivideOverflow;
                else
                  Status_S <= NormalAAndD;
                end if;
                state <= State_Start;
              end if;
            when others => null;
          end case;
        end if;
    end process control;
    
end Behavioral;
