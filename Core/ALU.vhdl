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

entity ALU is
  
  port (
    RegisterB   : in  Word;
    RegisterC   : in  Word;
    Instruction : in  Word;
    RegisterA   : out Word;
    RegisterD   : out Word;
    Carry       : out std_logic;
    OutputReady : out std_logic;
    Status : out std_logic_vector(1 downto 0));

end ALU;

architecture Behavioral of ALU is
  constant OperatorOr : std_logic_vector(1 downto 0) := "00";
  constant OperatorAnd : std_logic_vector(1 downto 0) := "01";
  constant OperatorXor : std_logic_vector(1 downto 0) := "10";

  constant OperatorAdd : std_logic_vector(1 downto 0) := "00";
  constant OperatorSub : std_logic_vector(1 downto 0) := "01";
  constant OperatorMultiply : std_logic_vector(1 downto 0) := "10";
  constant OperatorDivide : std_logic_vector(1 downto 0) := "11";

  constant OperatorShiftRight : std_logic := '0';
  constant OperatorShiftLeft : std_logic := '1';
  
  constant OpSigned : std_logic := '0';
  constant OpUnsigned : std_logic := '1';

  constant OperatorEqual : std_logic := '0';
  constant OperatorLessThan : std_logic := '1';

  constant NormalAOnly : std_logic_vector(1 downto 0) := "00";
  constant DivideOverflow : std_logic_vector(1 downto 0) := "01";
  constant NormalAAndD : std_logic_vector(1 downto 0) := "10";
  constant GenericError : std_logic_vector(1 downto 0) := "11";

  signal Opcode_S : Opcode;
  signal Operator_S : Operator;
  signal RegisterReferenceA : RegisterReference;
  signal RegisterReferenceB : RegisterReference;
  signal RegisterReferenceC : RegisterReference;
  signal RegisterReferenceD : RegisterReference;
  signal ImmediateValue_S : ImmediateValue;
  signal RegisterA_S : std_logic_vector(32 downto 0);
  signal RegisterD_S : std_logic_vector(32 downto 0);
  signal Carry_S : std_logic;
  
  
begin  -- Behavioral

  Opcode_S <= GetOpcode(Instruction);
  Operator_S <= GetOperator(Instruction);
  RegisterReferenceA <= GetRegisterReferenceA(Instruction);
  RegisterReferenceB <= GetRegisterReferenceB(Instruction);
  RegisterReferenceC <= GetRegisterReferenceC(Instruction);
  RegisterReferenceD <= GetRegisterReferenceD(Instruction);
  ImmediateValue_S <= GetImmediateValue(Instruction);
  RegisterA <= RegisterA_S(31 downto 0);
  RegisterD <= RegisterD_S(31 downto 0);
  Carry <= Carry_S;
  
  Math: process (Opcode_S, Operator_S, RegisterReferenceA, RegisterReferenceB, RegisterReferenceC, RegisterReferenceD, ImmediateValue_S, RegisterB, RegisterC)
  variable Product : std_logic_vector(63 downto 0);
  variable SignExtendedImmediate : std_logic_vector(31 downto 0);
  variable Result : std_logic_vector(32 downto 0);
  
  begin  -- process Math
    
    case Opcode_S is
      when OpcodeLogical =>
        case Operator_S(2 downto 1) is
          
          when OperatorOr =>            -- Or
             case Operator_S(0) is
             when RegisterMode =>
               RegisterD_S <= (others => '0');
               RegisterA_S <= "0" & (RegisterB or RegisterC);
               Carry_S <= '0';
               OutputReady <= '1';
               Status <= NormalAOnly;
             when ImmediateMode =>
               RegisterD_S <= (others => '0');
               RegisterA_S <= "0" & (RegisterB or ("0000000000000000" & ImmediateValue_S));
               OutputReady <= '1';
               Carry_S <= '0';
               Status <= NormalAOnly;
             when others =>
               Carry_S <= '0';
                OutputReady <= '1';
                Status <= GenericError;
           end case;

          when OperatorAnd =>  -- And
             case Operator_S(0) is
             when RegisterMode =>
               RegisterD_S <= (others => '0');
               RegisterA_S <= "0" & (RegisterB and RegisterC);
               OutputReady <= '1';
               Carry_S <= '0';
               Status <= NormalAOnly;
             when ImmediateMode =>
              RegisterD_S <= (others => '0');
               RegisterA_S <= "0" & (RegisterB and ("0000000000000000" & ImmediateValue_S));
              OutputReady <= '1';
              Carry_S <= '0';
               Status <= NormalAOnly;
             when others =>
                Carry_S <= '0';
                OutputReady <= '1';
                Status <= GenericError;
           end case;

          when OperatorXor =>           --Xor
            case Operator_S(0) is
             when RegisterMode =>
               RegisterD_S <= (others => '0');
               RegisterA_S <= "0" & (RegisterB xor RegisterC);
               OutputReady <= '1';
               Carry_S <= '0';
               Status <= NormalAOnly;
             when ImmediateMode =>
               RegisterD_S <= (others => '0');
               RegisterA_S <= "0" & (RegisterB xor ("0000000000000000" & ImmediateValue_S));
               OutputReady <= '1';
               Carry_S <= '0';
               Status <= NormalAOnly;
             when others =>
                Carry_S <= '0';
                OutputReady <= '1';
                Status <= GenericError;
           end case;
 
          when others =>
                OutputReady <= '1';
                Status <= GenericError;
        end case;
      when OpcodeArithmetic =>
        case Operator_S(2 downto 1) is
          
          when OperatorAdd =>           -- Add
            case Operator_S(0) is
              when RegisterMode =>
               RegisterD_S <= (others => '0');
                Result := std_logic_vector(("0" & unsigned(RegisterB)) + ("0" & unsigned(RegisterC)));
               RegisterA_S <= Result;
               OutputReady <= '1';
               Carry_S <= Result(32);
               Status <= NormalAOnly;
              when ImmediateMode =>
                SignExtendedImmediate:= std_logic_vector(resize(signed(ImmediateValue_S), 32));
               RegisterD_S <= (others => '0');
                Result  := std_logic_vector(("0" & unsigned(RegisterB)) + ("0" & unsigned(SignExtendedImmediate)));
                OutputReady <= '1';
                RegisterA_S <= Result;
                Carry_S <= Result(32);
               Status <= NormalAOnly;
              when others =>
                 Carry_S <= '0';
                 OutputReady <= '1';
                Status <= GenericError;
            end case;

          when OperatorSub =>           -- Sub
            case Operator_S(0) is
              when RegisterMode =>
               RegisterD_S <= (others => '0');
                Result := std_logic_vector(("0" & unsigned(RegisterB)) - ("0" & unsigned(RegisterC)));
               OutputReady <= '1';
               RegisterA_S <= Result;
               Carry_S <= Result(32);
               Status <= NormalAOnly;
              when ImmediateMode =>
                SignExtendedImmediate:= std_logic_vector(resize(signed(ImmediateValue_S), 32));--std_logic_vector(not(resize(signed(ImmediateValue_S), 32)) + 1);
               RegisterD_S <= (others => '0');
                Result := std_logic_vector(("0" & unsigned(RegisterB)) - ("0" & unsigned(SignExtendedImmediate)));
                RegisterA_S <= Result;
                OutputReady <= '1';
               Carry_S <= Result(32);
               Status <= NormalAOnly;
              when others =>
                 Carry_S <= '0';
                 OutputReady <= '1';
                Status <= GenericError;
            end case;
          when OperatorMultiply =>           -- Multiply
            case Operator_S(0) is
              when RegisterMode =>
                Product:= std_logic_vector(unsigned(RegisterB) * unsigned(RegisterC));
                RegisterD_S <= (others => '0');
                RegisterA_S <= Product(32 downto 0);
                OutputReady <= '1';
                Carry_S <= '0';
               Status <= NormalAOnly;
              when ImmediateMode =>
                SignExtendedImmediate:= std_logic_vector(resize(signed(ImmediateValue_S), 32));
                Product:= std_logic_vector(unsigned(RegisterB) * unsigned(SignExtendedImmediate));
               RegisterD_S <= "0" & Product(63 downto 32);
               RegisterA_S <= Product(32 downto 0);
               OutputReady <= '1';
                Carry_S <= '0';
               Status <= NormalAOnly;
              when others =>
                Carry_S <= '0';
                 OutputReady <= '1';
                Status <= GenericError;
            end case;

--          when OperatorDivide =>           -- Divide And Remainder
--            case Operator_S(0) is
--              when RegisterMode =>
--                
--               OutputReady <= '1';
--                if signed(RegisterC) = 0 then
--                  OutputReady <= '1';
--                  Carry_S <= '0';
--                  Status <= DivideOverflow;
--                  RegisterA_S <= (others => '0');
--                  RegisterD_S <= (others => '0');
--                else
--                  Carry_S <= '0';
--                  RegisterA_S <= "0" & std_logic_vector(signed(RegisterB) / signed(RegisterC));
--                  RegisterD_S <= "0" & std_logic_vector(signed(RegisterB) rem signed(RegisterC));
--                  OutputReady <= '1';
--                  Status <= NormalAAndD;
--                end if;
--              when ImmediateMode =>
--                 SignExtendedImmediate := std_logic_vector(resize(signed(ImmediateValue_S), 32));
--                 OutputReady <= '1';
--                if signed(SignExtendedImmediate) = 0 then
--                  OutputReady <= '1';
--                  Carry_S <= '0';
--                  Status <= DivideOverflow;
--                  RegisterA_S <= (others => '0');
--                  RegisterD_S <= (others => '0');
--                else
--                  Carry_S <= '0';
--                  RegisterA_S <= "0" & std_logic_vector(signed(RegisterB) / signed(SignExtendedImmediate));
--                  RegisterD_S <= "0" & std_logic_vector(signed(RegisterB) rem signed(SignExtendedImmediate));
--                  OutputReady <= '1';
--                  Status <= NormalAAndD;
--                end if;
--              when others =>
--                Carry_S <= '0';
--                 OutputReady <= '1';
--                Status <= GenericError;
--            end case;
            
          when others =>
            Carry_S <= '0';
             OutputReady <= '1';
                Status <= GenericError;
        end case;
    when OpcodeShift =>
        case Operator_S(2) is
          when OperatorShiftRight =>
            case Operator_S(1) is
              when OpUnsigned =>
                case Operator_S(0) is
                  when RegisterMode =>
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= std_logic_vector(shift_right("0" & unsigned(RegisterB),to_integer("0" & unsigned(RegisterC))));
                    OutputReady <= '1';
                    Status <= NormalAOnly;
                  when ImmediateMode =>
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= std_logic_vector(shift_right("0" & unsigned(RegisterB),to_integer(unsigned(ImmediateValue_S))));
                    OutputReady <= '1';
                    Status <= NormalAOnly;
                  when others =>
                    Carry_S <= '0';
                     OutputReady <= '1';
                     Status <= GenericError;
                end case;
              when OpSigned =>
                case Operator_S(0) is
                  when RegisterMode =>
                    RegisterD_S <= (others => '0');
                  RegisterA_S <= std_logic_vector(shift_right("0" & signed(RegisterB),to_integer("0" & unsigned(RegisterC))));
                    OutputReady <= '1';
                    Status <= NormalAOnly;
                  when ImmediateMode =>
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= std_logic_vector(shift_right("0" & signed(RegisterB),to_integer(unsigned(ImmediateValue_S))));
                    OutputReady <= '1';
                    Status <= NormalAOnly;
                    Carry_S <= '0';
                  when others =>
                    Carry_S <= '0';
                     OutputReady <= '1';
                     Status <= GenericError;
                end case;
              when others =>
                 OutputReady <= '1';
                 Carry_S <= '0';
                Status <= GenericError;
            end case;
          when OperatorShiftLeft =>
            case Operator_S(1) is
              when OpUnsigned =>
                case Operator_S(0) is
                  when RegisterMode =>
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= std_logic_vector(shift_left("0" & unsigned(RegisterB),to_integer("0" & unsigned(RegisterC))));
                    OutputReady <= '1';
                    Carry_S <= '0';
                    Status <= NormalAOnly;
                  when ImmediateMode =>
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= std_logic_vector(shift_left("0" & unsigned(RegisterB),to_integer(unsigned(ImmediateValue_S))));
                    OutputReady <= '1';
                    Carry_S <= '0';
                    Status <= NormalAOnly;
                  when others =>
                    Carry_S <= '0';
                     OutputReady <= '1';
                     Status <= GenericError;
                end case;
              when OpSigned =>
                case Operator_S(0) is
                  when RegisterMode =>
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= std_logic_vector(shift_left("0" & signed(RegisterB),to_integer("0" & unsigned(RegisterC))));
                    OutputReady <= '1';
                    Carry_S <= '0';
                    Status <= NormalAOnly;
                  when ImmediateMode =>
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= std_logic_vector(shift_left("0" & signed(RegisterB),to_integer(unsigned(ImmediateValue_S))));
                    OutputReady <= '1';
                    Carry_S <= '0';
                    Status <= NormalAOnly;
                  when others =>
                     OutputReady <= '1';
                     Carry_S <= '0';
                Status <= GenericError;
                end case;
              when others =>
                 OutputReady <= '1';
                 Carry_S <= '0';
                Status <= GenericError;
            end case;
          when others =>
             OutputReady <= '1';
             Carry_S <= '0';
                Status <= GenericError;
        end case;
      when OpcodeRelational =>
        case Operator_S(2) is
          when OperatorLessThan =>
            case Operator_S(1) is
              when OpUnsigned =>
              case Operator_S(0) is
                when RegisterMode =>
                 if ("0" & unsigned(RegisterB)) < ("0" & unsigned(RegisterC)) then
                   RegisterD_S <= (others => '0');
                   RegisterA_S <= (0 => '1', others => '0');
                 else
                   RegisterD_S <= (others => '0');
                   RegisterA_S <= (0 => '0', others => '0');
                 end if;
                 OutputReady <= '1';
                 Carry_S <= '0';
                 Status <= NormalAOnly;
                when ImmediateMode =>
                  if ("0" & unsigned(RegisterB)) < unsigned(ImmediateValue_S) then
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= (0 => '1', others => '0');
                  else
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= (0 => '0', others => '0');
                   OutputReady <= '1';
                    Carry_S <= '0';
                   Status <= NormalAOnly;
                 end if;   
                when others =>
                   OutputReady <= '1';
                   Carry_S <= '0';
                Status <= GenericError;
              end case;
              when OpSigned =>
              case Operator_S(0) is
                when RegisterMode =>
                 if signed(RegisterB) < signed(RegisterC) then
                   RegisterD_S <= (others => '0');
                   RegisterA_S <= (0 => '1', others => '0');
                 else
                   RegisterD_S <= (others => '0');
                   RegisterA_S <= (0 => '0', others => '0');
                 end if;
                    OutputReady <= '1';
                 Carry_S <= '0';
                    Status <= NormalAOnly;
                when ImmediateMode =>
                  if signed(RegisterB) < signed(ImmediateValue_S) then
                    RegisterD_S <= (others => '0');
                    RegisterA_S <= (0 => '1', others => '0');
                 else
                   RegisterD_S <= (others => '0');
                   RegisterA_S <= (0 => '0', others => '0');
                  
                 end if;
                    OutputReady <= '1';
                    Carry_S <= '0';
                  Status <= NormalAOnly;
                when others =>
                    OutputReady <= '1';
                    Carry_S <= '0';
                    Status <= GenericError;
              end case;
              when others =>
                OutputReady <= '1';
                Carry_S <= '0';
                Status <= GenericError;
            end case;
          when OperatorEqual =>
            case Operator_S(0) is
              when RegisterMode =>
                 if RegisterB = RegisterC then
                   RegisterD_S <= (others => '0');
                   RegisterA_S <= (0 => '1', others => '0');
                 else
                   RegisterD_S <= (others => '0');
                   RegisterA_S <= (0 => '0', others => '0');
                 end if;
                 Carry_S <= '0';
                  OutputReady <= '1';
                  Status <= NormalAOnly;
              when ImmediateMode =>
                case Operator_S(1) is
                  when OpUnsigned =>
                    if ("0" & unsigned(RegisterB)) = unsigned(ImmediateValue_S) then
                      RegisterD_S <= (others => '0');
                      RegisterA_S <= (0 => '1', others => '0');
                    else
                      RegisterD_S <= (others => '0');
                      RegisterA_S <= (0 => '0', others => '0');
                    end if;
                    Carry_S <= '0';
                    OutputReady <= '1';
                    Status <= NormalAOnly;
                  when OpSigned =>
                    if ("0" & signed(RegisterB)) = signed(ImmediateValue_S) then
                      RegisterD_S <= (others => '0');
                      RegisterA_S <= (0 => '1', others => '0');
                    else
                      RegisterD_S <= (others => '0');
                      RegisterA_S <= (0 => '0', others => '0');
                    end if;
                    OutputReady <= '1';
                    Carry_S <= '0';
                    Status <= NormalAOnly;
                  when others =>
                     OutputReady <= '1';
                     Carry_S <= '0';
                     Status <= GenericError;
                end case;
              when others =>
                 OutputReady <= '1';
                 Carry_S <= '0';
                 Status <= GenericError;
            end case;
          when others =>
             OutputReady <= '1';
             Carry_S <= '0';
             Status <= GenericError;
        end case;
        
      when others =>
         OutputReady <= '1';
         Carry_S <= '0';
         Status <= GenericError;
    end case;
    
  end process Math;
end Behavioral;
