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
use work.Constants.ALL;

entity OmegaTop is
 port(
	CLK : in std_logic;
	RX : in std_logic;
	TX : out std_logic
 );
end OmegaTop;

architecture Behavioral of OmegaTop is
	 component MemoryController is

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
  component UARTClockManager is
    port
      (-- Clock in ports
        CLK_IN1           : in     std_logic;
        -- Clock out ports
        CLK_OUT1          : out    std_logic;
        CLK_OUT2          : out    std_logic;
        -- Status and control signals
        RESET             : in     std_logic
        );
  end component UARTClockManager;
  component PortController is
    port (
      CLK  : in std_logic;
		CLK16x : in std_logic;
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

  signal CLK_s : std_logic;
  signal CLK_16x_s : std_logic;
  signal MemControllerDone_s : std_logic := '0';
  signal MemControllerFromRead_s : Word := (others => '0');
  signal MemControllerToWrite_s : Word := (others => '0');
  signal MemControllerADDR_s : Word := (others => '0');
  signal MemControllerEnable_s : std_logic := '0';
  signal Instr_s : Word := (others => '0');
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
  
begin
  MemoryControllerControl : MemoryController port map (
    Address     => MemControllerADDR_s,
    ToWrite     => MemControllerToWrite_s,
    FromRead    => MemControllerFromRead_s,
    Enable      => MemControllerEnable_s,
    Instruction => Instr_s,
    Reset       => RST,
    Done        => MemControllerDone_s,
    CLK         => CLK_s);

 PortControl : PortController port map (
    CLK => CLK_s,
	 CLK16x => CLK_16x_s,
    XMit => PortXMit_s,
    Recv => PortRecv_s,
    instruction => Instr_s,
    CPUReady => PortCPUReady_s,
    CPUSending => PortCPUSending_s,
    SerialIn => RX,
	 SerialOut => TX,
    PortReady => PortReady_s,
    Done => PortDone_s,
    PortSending => PortSending_s);
clockManager : UARTClockManager port map (
    CLK_IN1 => clk,
    CLK_OUT1 => CLK_16x_s,
	 CLK_OUT2 => CLK_s,
    RESET => '0'
    );
  
  Omega_Control : Control port map (
    CLK => CLK_s,
    MemControllerDone => MemControllerDone_s,
    MemControllerFromRead => MemControllerFromRead_s,
    MemControllerToWrite => MemControllerToWrite_s,
    MemControllerADDR => MemControllerADDR_s,
    MemControllerEnable => MemControllerEnable_s,
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
    Instr => Instr_s);


end Behavioral;

