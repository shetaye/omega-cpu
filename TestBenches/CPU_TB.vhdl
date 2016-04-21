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
use std.textio.all;
use work.ghdl_env.all;

entity CPU_TB is
  
end CPU_TB;

architecture Behavioral of CPU_TB is

  component  MemoryController is

    port (
      CLK         : in std_logic;
      Address     : in  word;
      ToWrite     : in  word;
      FromRead    : out word;
      Instruction : in  word;
      Enable      : in std_logic;
      Reset       : in std_logic;
      Done        : out std_logic);
    
  end component MemoryController;

  component PortController is
    port (
      CLK  : in std_logic;
      XMit : in Word;
      Recv : out Word;
      SerialIn : in std_logic;
      SerialOut : out std_logic;
      instruction : in Word;
      CPUReady : in std_logic;
      CPUSending: in std_logic;
      PortReady: out std_logic;
      PortSending: out std_logic;
      Done: out std_logic);
  end component PortController;

  component Control is

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
      Instr : out Word;
      RST : in std_logic);
    
    
  end component Control;

  signal MemControllerDone : std_logic := '0';
  signal MemControllerFromRead : Word := (others => '0');
  signal MemControllerToWrite : Word := (others => '0');
  signal MemControllerADDR : Word := (others => '0');
  signal MemControllerEnable : std_logic := '0';
  signal Instr : Word := (others => '0');
  signal MemoryPassthrough : std_logic := '0';
  signal CLK : std_logic := '0';
  signal RST : std_logic := '0';
--port
  signal PortXmit_s :  Word;
  signal PortRecv_s : Word;
  signal PortInstruction_s :  Word;
  signal PortCPUReady_s :  std_logic;
  signal PortCPUSending_s :  std_logic;
  signal PortReady_s :  std_logic;
  signal PortDone_s :  std_logic;
  signal PortSending_s :  std_logic;
  --mem
  signal MemControllerDone_M : std_logic;
  signal MemControllerFromRead_M : Word;
  signal MemControllerToWrite_M : Word;
  signal MemControllerADDR_M : Word;
  signal MemControllerReset_M : std_logic := '0';
  signal Instr_M : Word;
  signal MemControllerEnable_M : std_logic;
  signal MemControllerEnable_C : std_logic;
  signal MemControllerDone_C : std_logic;
  signal MemControllerFromRead_C : Word;
  signal MemControllerToWrite_C : Word;
  signal MemControllerADDR_C : Word;
  signal Instr_C : Word;
  
  begin

  MemoryControllerControl : MemoryController port map (
    Address     => MemControllerADDR_M,
    ToWrite     => MemControllerToWrite_M,
    FromRead    => MemControllerFromRead_M,
    Enable      => MemControllerEnable_M,
    Instruction => Instr_M,
    Reset       => MemControllerReset_M,
    Done        => MemControllerDone_M,
    CLK         => CLK);

 PortControl : PortController port map (
    CLK => CLK,
    XMit => PortXMit_s,
    Recv => PortRecv_s,
    instruction => Instr_C,
    CPUReady => PortCPUReady_s,
    CPUSending => PortCPUSending_s,
    SerialIn => '0',
    PortReady => PortReady_s,
    Done => PortDone_s,
    PortSending => PortSending_s);

  
  ControlTB : Control port map (
    CLK => CLK,
    MemControllerDone => MemControllerDone_C,
    MemControllerFromRead => MemControllerFromRead_C,
    MemControllerToWrite => MemControllerToWrite_C,
    MemControllerADDR => MemControllerADDR_C,
    MemControllerEnable => MemControllerEnable_C,
    PortXmit => PortXmit_s,
    PortRecv => PortRecv_s,
    PortInstruction => PortInstruction_s,
    PortCPUReady => PortCPUReady_s,
    PortCPUSending => PortCPUSending_s,
    PortReady => PortReady_s,
    PortDone =>  PortDone_s,
    PortSending =>  PortSending_s,
    IRQ => (others => '0'),
    RST => RST,
    Instr => Instr_C);

  file_io:
  process is
    file programInput : text is in getenv("PROGRAM");
    variable in_line : line;
    variable out_line : line;
    variable in_vector : bit_vector(31 downto 0) := (others => '0');
    variable outputI : integer := 0;
    variable Counter : integer := 0;
    variable NextWord : Word := (others => '0');
  begin  -- Behiavioral
    
    

    while not endfile(programInput) loop
      readline(programInput, in_line);
      if in_line'length = 32 then
        read(in_line, in_vector);
        NextWord := to_stdlogicvector(in_vector);
        MemControllerToWrite <= std_logic_vector(resize(unsigned(NextWord(7 downto 0)), 32));
        Instr <= OpcodeMemory & StoreByte & "00000" & "000000000000000000000";
        MemControllerADDR <= std_logic_vector(to_unsigned(Counter, 32));
        wait for 1 ns;
        MemControllerEnable <= '1';
        wait for 1 ns;
        MemControllerEnable <= '0';
        wait for 1 ns;
         MemControllerToWrite <= std_logic_vector(resize(unsigned(NextWord(15 downto 8)), 32));
        Instr <= OpcodeMemory & StoreByte & "00000" & "000000000000000000000";
        MemControllerADDR <= std_logic_vector(to_unsigned(Counter + 1, 32));
        wait for 1 ns;
        MemControllerEnable <= '1';
        wait for 1 ns;
        MemControllerEnable <= '0';
        wait for 1 ns;
         MemControllerToWrite <= std_logic_vector(resize(unsigned(NextWord(23 downto 16)), 32));
        Instr <= OpcodeMemory & StoreByte & "00000" & "000000000000000000000";
        MemControllerADDR <= std_logic_vector(to_unsigned(Counter + 2, 32));
        wait for 1 ns;
        MemControllerEnable <= '1';
        wait for 1 ns;
        MemControllerEnable <= '0';
        wait for 1 ns;
         MemControllerToWrite <= std_logic_vector(resize(unsigned(NextWord(31 downto 24)), 32));
        Instr <= OpcodeMemory & StoreByte & "00000" & "000000000000000000000";
        MemControllerADDR <= std_logic_vector(to_unsigned(Counter + 3, 32));
        wait for 1 ns;
        MemControllerEnable <= '1';
        wait for 1 ns;
        MemControllerEnable <= '0';
        Counter := Counter + 4;
      else
        writeline(output,in_line);
      end if;
    end loop;
    wait for 2 ns;
    MemoryPassthrough <= '1';
    RST <= '1';
    wait for 2 ns;
    RST <= '0';

    loop

      wait for 100 ns;
      CLK <= '1';
      wait for 100 ns;
      CLK <= '0';
      
    end loop;  -- N

    wait;
    
  end process;

  Passthrough: process (MemControllerDone,MemControllerFromRead,MemControllerToWrite,MemControllerADDR,Instr,MemControllerEnable_C,MemControllerEnable,MemoryPassthrough,MemControllerADDR_C,Instr_C,MemControllerToWrite_C,MemControllerDone_M,MemControllerFromRead_M) is
  begin
    if MemoryPassthrough = '1' then
      MemControllerADDR_M <= MemControllerADDR_C;
      Instr_M <= Instr_C;
      MemControllerToWrite_M <= MemControllerToWrite_C;
      MemControllerDone_C <= MemControllerDone_M;
      MemControllerFromRead_C <= MemControllerFromRead_M;
      MemControllerEnable_M <= MemControllerEnable_C;
    else
      MemControllerADDR_M <= MemControllerADDR;
      Instr_M <= Instr;
      MemControllerEnable_M <= MemControllerEnable;
      MemControllerToWrite_M <= MemControllerToWrite;
      MemControllerDone <= MemControllerDone_M;
      MemControllerFromRead <= MemControllerFromRead_M;
      MemControllerDone_C <= '0';
      MemControllerFromRead_C <= (others => '0');
    end if;
  end process;

end Behavioral;
