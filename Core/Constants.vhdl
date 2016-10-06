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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package Constants is

  subtype Byte is std_logic_vector (7 downto 0);
  -- FIXME: Change "12" to "4095" when using GHDL simulator.
  type MemoryArray is array(0 to 12) of Byte;

  subtype Word is std_logic_vector (31 downto 0);
  subtype Opcode is std_logic_vector (2 downto 0);
  subtype Operator is std_logic_vector (2 downto 0);
  subtype RegisterReference is std_logic_vector (4 downto 0);
  subtype ImmediateValue is std_logic_vector (15 downto 0);
  subtype ImmediateAddress is std_logic_vector (25 downto 0);
  subtype ImmediateConditionalAddress is std_logic_vector(20 downto 0);

  function GetOpcode (
    W : Word)
    return std_logic_vector; --Opcode

  function GetOperator (
    W : Word)
    return std_logic_vector; --Operator

  function GetRegisterReferenceA (
    W : Word)
    return std_logic_vector; --RegisterReference
  function GetRegisterReferenceB (
    W : Word)
    return std_logic_vector; --RegisterReference
  function GetRegisterReferenceC   (
    W : Word)
    return std_logic_vector; --RegisterReference
  function GetRegisterReferenceD (
    W : Word)
    return std_logic_vector; --RegisterReference

  function GetImmediateValue (
    W : Word)
    return std_logic_vector; --ImmediateValue

  function GetImmediateAddress (
    W : Word)
    return std_logic_vector; --ImmediateAddress

  function GetImmediateConditionalAddress
    ( W : Word)
    return std_logic_vector; --ImmediateConditionalAddress

  function SignExtendImmediateValue (
    VALUE : ImmediateValue)
    return std_logic_vector; --Word

  function SignExtendImmediateAddress (
    ADDR : ImmediateAddress)
    return std_logic_vector; --Word

  function SignExtendImmediateConditionalAddress (
    ADDR : ImmediateConditionalAddress)
    return std_logic_vector; --Word

  function GetIRQ (
    IRQ : std_logic_vector(23 downto 0))
    return integer;

    
constant OpcodeLogical : opcode := "000";
constant OpcodeArithmetic : opcode := "001";
constant OpcodeShift : opcode := "010";
constant OpcodeRelational : opcode := "011";
constant OpcodeMemory : opcode := "100";
constant OpcodePort : opcode := "101";
constant OpcodeBranch : opcode := "110";
constant RegisterMode : std_logic := '0';
constant ImmediateMode : std_logic := '1';
constant LoadByteUnsigned : Operator := "000";
constant LoadByteSigned : Operator := "001";
constant LoadHalfWordUnsigned : Operator := "010";
constant LoadHalfWordSigned : Operator := "011";
constant LoadWord : Operator := "100";
constant StoreByte : Operator := "101";
constant StoreHalfWord : Operator := "110";
constant StoreWord : Operator := "111";
constant NormalAOnly : std_logic_vector(1 downto 0) := "00";
constant DivideOverflow : std_logic_vector(1 downto 0) := "01";
constant NormalAAndD : std_logic_vector(1 downto 0) := "10";
constant GenericError : std_logic_vector(1 downto 0) := "11";
constant InterruptTableADDR : Word := "11111111111111111111111110000000";
constant JumpToReg29 : Word := "11000000000111010000000000000000";
  
end Constants;

package body Constants is
  function GetOpcode (
    W : Word)
    return std_logic_vector is --Opcode
  begin
    return w (31 downto 29);
  end;

  function GetOperator (
    W : Word)
    return std_logic_vector is --Operator
  begin
    return w (28 downto 26);
  end;

  function GetRegisterReferenceA (
    W : Word)
    return std_logic_vector is --RegisterReference
  begin
    return w (25 downto 21);
  end;
  function GetRegisterReferenceB (
    W : Word)
    return std_logic_vector is --RegisterReference
  begin
    return w (20 downto 16);
  end;
  function GetRegisterReferenceC   (
    W : Word)
    return std_logic_vector is --RegisterReference
  begin
    return w (15 downto 11);
  end;
  function GetRegisterReferenceD (
    W : Word)
    return std_logic_vector is --RegisterReference
  begin
    return w (10 downto 6);
  end;

  function GetImmediateValue (
    W : Word)
    return std_logic_vector is --ImmediateValue
  begin
    return w (15 downto 0);
  end;

  function GetImmediateAddress (
    W : Word)
    return std_logic_vector is --ImmediateAddress
  begin
    return w (25 downto 0);
  end;

  function GetImmediateConditionalAddress (
    W : Word)
    return std_logic_vector is --ImmediateConditionalAddress
  begin
    return w (20 downto 0);
  end;

  function SignExtendImmediateValue (
   VALUE : ImmediateValue)
    
    return std_logic_vector is --Word
  begin  -- SignExtendImmediate
    return std_logic_vector(resize(signed(VALUE), 32));
  end SignExtendImmediateValue;

  function SignExtendImmediateAddress (
    ADDR : ImmediateAddress)
    
    return std_logic_vector is --Word
  begin  -- SignExtendImmediateAddress
    return std_logic_vector(resize(signed(unsigned(ADDR) & "00"), 32));
  end SignExtendImmediateAddress;

  function SignExtendImmediateConditionalAddress (
    ADDR : ImmediateConditionalAddress)
    
    return std_logic_vector is --Word
  begin  -- SignExtendImmediateAddress
    return std_logic_vector(resize(signed(unsigned(ADDR) & "00"), 32));
  end SignExtendImmediateConditionalAddress;

  function GetIRQ(
    IRQ : std_logic_vector(23 downto 0))
    return integer is
  begin
    for i in 0 to 23 loop
      if IRQ (i) /= '0' then
        return i;
      end if;
    end loop;  -- i
    return -1;
  end GetIRQ;
  

end Constants;
