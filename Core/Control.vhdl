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

entity Control is

  port(
    CLK : in std_logic;
    MemControllerDone : in std_logic;
    MemControllerFromRead : in  Word;
    MemControllerToWrite : out Word;
    MemControllerADDR : out Word;
    MemControllerEnable : out std_logic;
	 PortXmit : out Word;
	 PortRecv : in Word;
	 PortInstruction : out Word;
	 PortCPUReady : out std_logic;
	 PortCPUSending : out std_logic;
    PortReady : in std_logic;
    PortDone : in std_logic;
    PortSending : out std_logic;	 
    IRQ : in std_logic_vector(23 downto 0);
    RST : in std_logic;
    Instr : out Word
    );
  
  
end Control;

architecture Behavioral of Control is
  

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

  component BranchUnit is

    port (
      Instruction : in Word;
      RegisterA : in Word;
      RegisterB : in Word;
      NewPC : out Word;
      CurrentPC : in Word;
      OutputReady : out std_logic);
  end component BranchUnit;

  component PortController
    
    
	 port (
    CLK  : in std_logic;
    XMit : in word;
    Recv : out word;
    instruction : in word;
    CPUReady : in std_logic;
    CPUSending: in std_logic;
    PortReady: out std_logic;
    Done: out std_logic;
    PortSending: out std_logic);
  end component;
  
  type MachineState is (Start, WaitForInstrRead,StoreMemOutToInstrR, AdvanceInstr, ALUHandle, ALUSetInstrIn, ALUOutReady, ALUSetOutReg, DecodeOpcode, MemSetInstrIn, MemSetOutReg, SetBranchInputs, ServiceInterrupt, PortSetInstrIn, PortSetOutReg);
  type RegisterArray is array(0 to 31) of Word;
  signal State : MachineState := Start;
  signal registers : RegisterArray := (others => (others => '0'));
  signal RegA : Word;
  signal RegB : Word;
  signal RegC : Word;
  signal RegD : Word;
  signal RegAOut : Word;
  signal RegBOut : Word;
  signal RegCOut : Word;
  signal RegDOut : Word;
  signal ALUStatus : std_logic_vector(1 downto 0);
  signal Instr_S : Word := (others => '0');
  signal ALUOutputReady : std_logic;
  signal BranchNP : Word;
  signal BranchOutReady : std_logic;
  signal MemControllerEnable_S : std_logic := '0';
  signal MemControllerADDR_S : Word := (others => '0');
  signal MemControllerToWrite_S : Word := (others => '0');
  signal IRQ_S : std_logic_vector(23 downto 0) := (others => '0');
  signal ServicingInterrupt : std_logic := '0';
  signal PortXMit_s : Word;
  signal PortRecv_s : Word;
  signal PortCPUReady_s : std_logic := '0';
  signal PortCPUSending_s : std_logic := '0';
  signal PortReadyPort : std_logic := '0';
  signal PortSendingPort : std_logic := '0';
  signal PortDone_s : std_logic := '0';
  signal Carry : std_logic := '0';

begin  -- Behavioral

  ALUControl : ALU port map (
    RegisterB => RegB,
    RegisterA => RegAOut,
    RegisterC => RegC,
    RegisterD => RegDOut,
    Instruction => Instr_S,
    OutputReady => ALUOutputReady,
    Carry => Carry,
    Status => ALUStatus);

  BranchUnitControl : BranchUnit port map (
    Instruction => Instr_S,
    RegisterA   => RegA,
    RegisterB   => RegB,
    NewPC       => BranchNP,
    CurrentPC   => Registers(31),
    OutputReady => BranchOutReady);

  
  MemControllerEnable <= MemControllerEnable_S;
  MemControllerADDR <= MemControllerADDR_S;
  MemControllerToWrite <= MemControllerToWrite_S;
  
  PortXMit <= PortXmit_s;
  PortRecv_s <= PortRecv;
  PortInstruction <= Instr_s;
  PortCPUReady <= PortCPUReady_s;
  PortCPUSending <= PortCPUSending_s;
  PortReadyPort <= PortReady;
  PortSending <= PortSendingPort;
  
  process (Registers, Instr_S)

  begin  -- process

    RegA <= Registers(to_integer(unsigned(GetRegisterReferenceA(Instr_S))));
    RegB <= Registers(to_integer(unsigned(GetRegisterReferenceB(Instr_S))));
    RegC <= Registers(to_integer(unsigned(GetRegisterReferenceC(Instr_S))));
    RegD <= Registers(to_integer(unsigned(GetRegisterReferenceD(Instr_S))));

    Instr <= Instr_S;
    
  end process;

  --process (IRQ)
  --   begin  -- process

  --     IRQ_S <= IRQ_S or IRQ;
       
  --   end process;   

  StateMachine: process (CLK, RST)
    variable ReadValue : integer := 0;
    variable ReadValue_D : integer := 0;
    variable NextInterrupt : integer := -1;
    variable SignExtendedImmediate : std_logic_vector(31 downto 0);
    variable ImmediateValue_v : std_logic_vector(15 downto 0);
  begin  -- process StateMachine
    if RST = '1' then
      Registers <= (others => (others => '0'));
      State <= Start;
      MemControllerEnable_S <= '0';
    elsif rising_edge(CLK) then
      case State is
        when Start =>
          if ServicingInterrupt = '0' and IRQ_S /= "000000000000000000000000" then
            NextInterrupt := GetIRQ(IRQ_S);
            if NextInterrupt /= -1 then
              IRQ_S(NextInterrupt) <= '0';
              MemControllerADDR_S <= std_logic_vector(unsigned(InterruptTableADDR) + (NextInterrupt * 4));
              State <= ServiceInterrupt;
              ServicingInterrupt <= '1';              
            end if;
          else
            MemControllerADDR_S <= registers(31);
            State <= WaitForInstrRead;
          end if;
          Instr_S <= OpcodeMemory & LoadWord & "00000" & "11111" & "0000000000000000";
          MemControllerEnable_S <= '0';
        when ServiceInterrupt =>
          if MemControllerDone = '1' then
            if MemControllerFromRead /= "00000000000000000000000000000000" then
              registers(29) <= registers(31);
              registers(31) <= MemControllerFromRead;
              
            end if;
            State <= Start;
            MemControllerEnable_S <= '0';
          else
            MemControllerEnable_S <= '1';
          end if;
        when WaitForInstrRead =>
          if MemControllerDone = '1' then
            Instr_S <= MemControllerFromRead;
            registers(31) <= std_logic_vector(unsigned(registers(31)) + 4);
            State <= DecodeOpcode;

            MemControllerEnable_S <= '0';
          else
            MemControllerEnable_S <= '1';
          end if;
        when DecodeOpcode =>
          case GetOpcode(Instr_S) is
            when OpcodeLogical|OpcodeArithmetic|OpcodeShift|OpcodeRelational =>
              State <= ALUSetInstrIn;
            when OpcodeMemory =>
              State <= MemSetInstrIn;
            when OpcodeBranch =>
              State <= SetBranchInputs;
            when OpcodePort =>
              State <= PortSetInstrIn;
            when others => null;   
          end case;
          if Instr_S = JumpToReg29 then
            ServicingInterrupt <= '0';
          end if;
          MemControllerEnable_S <= '0';
        when MemSetInstrIn =>
          case GetOperator(Instr_S) is
            when LoadByteUnsigned|LoadByteSigned|LoadHalfWordUnsigned|LoadHalfWordSigned|LoadWord =>
              --MemControllerADDR_S <= Registers(to_integer(unsigned(GetRegisterReferenceB(Instr_S))));
              ImmediateValue_v := GetImmediateValue(Instr_S);
              MemControllerADDR_S <= std_logic_vector(to_integer(unsigned(RegB)) + resize(signed(ImmediateValue_v), 32));
              if MemControllerDone = '1' then
                ReadValue := to_integer(unsigned(GetRegisterReferenceA(Instr_S)));
                if ReadValue /= 0 then
                Registers(ReadValue) <= MemControllerFromRead;
                end if;
                State <= Start;

                MemControllerEnable_S <= '0';
              else
                MemControllerEnable_S <= '1';
              end if;
            when StoreByte|StoreHalfWord|StoreWord =>
              --MemControllerADDR_S <= Registers(to_integer(unsigned(GetRegisterReferenceB(Instr_S))));
              ImmediateValue_v := GetImmediateValue(Instr_S);
              MemControllerADDR_S <= std_logic_vector(to_integer(unsigned(RegB)) + resize(signed(ImmediateValue_v), 32));
              MemControllerToWrite_S <= Registers(to_integer(unsigned(GetRegisterReferenceA(Instr_S))));
              if MemControllerDone = '1' then
                State <= Start;
                MemControllerEnable_S <= '0';
              else
                MemControllerEnable_S <= '1';
              end if;
            when others => null;
          end case;
       when PortSetInstrIn =>
          case GetOperator(Instr_S) is
            when LoadByteUnsigned|LoadByteSigned|LoadHalfWordUnsigned|LoadHalfWordSigned|LoadWord =>
              if PortReadyPort = '1' then
                ReadValue := to_integer(unsigned(GetRegisterReferenceA(Instr_S)));
                if ReadValue /= 0 then
                Registers(ReadValue) <= PortRecv_s;
                end if;
                State <= Start;
                PortCPUSending_s <= '0';
                PortCPUReady_s <= '0';
              else
                PortCPUSending_s <= '0';
                PortCPUReady_s <= '1';
                
              end if;
            when StoreByte|StoreHalfWord|StoreWord =>
              if PortDone = '1' then
                State <= Start;
                PortXMit_s <= (others => '0');
               PortCPUSending_s <= '0';
               PortCPUReady_s <= '0';
              else
               PortXMit_s <= Registers(to_integer(unsigned(GetRegisterReferenceA(Instr_S))));
                PortCPUSending_s <= '1';
                PortCPUReady_s <= '1';
              end if;
            when others => null;
          end case;
        when SetBranchInputs =>
          if BranchOutReady = '1' then
            Registers(31) <= BranchNP;
            MemControllerEnable_S <= '0';
            State <= Start;
          end if;
          
        when ALUSetInstrIn =>
          if ALUOutputReady = '1' then
            case ALUStatus is
              when NormalAOnly =>
                ReadValue := to_integer(unsigned(GetRegisterReferenceA(Instr_S)));
                if ReadValue /= 0 then
                   Registers(ReadValue) <= RegAOut;
                end if;
                Registers(30) <= (0 => Carry, others => '0');
              when DivideOverflow =>
                -- Fill In!
              when NormalAAndD =>
                ReadValue := to_integer(unsigned(GetRegisterReferenceA(Instr_S)));
                if ReadValue /= 0 then
                  Registers(ReadValue) <= RegAOut;
                end if;
                ReadValue_D := to_integer(unsigned(GetRegisterReferenceD(Instr_S)));
                if ReadValue_D /= 0 then
                  Registers(ReadValue_D) <= RegDOut;
                end if;

                Registers(30) <= (others => '0');
              when GenericError =>
                -- Fill In!
              when others => null;
            end case;
          end if;
          State <= Start;
          MemControllerEnable_S <= '0';
        when others => null;
      end case;
    end if;
  end process StateMachine;

end Behavioral;
