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
use IEEE.NUMERIC_STD.ALL;
library open16750;
use open16750.UART;
use work.Constants.ALL;

entity PortController is
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
end PortController;

architecture Behavioral of PortController is
component UART is
  generic (
    word_length    : integer range 5 to 8 := 8;
    stop_bits      : integer range 1 to 2 := 1;
    has_parity     : boolean := false;
    parity_is_even : boolean := false;
    baud_divisor   : integer range 1 to 65535 := 1);
  port (
    clk                   : in  std_logic;
    rst                   : in  std_logic;
    -- This clock should run at 16 times the baud rate.
    clk_16x               : in  std_logic;
    serial_out            : out std_logic;
    serial_in             : in  std_logic;
    din                   : in  std_logic_vector(7 downto 0);
    xmit_buffer_ready     : out std_logic;
    xmit_enable           : in  std_logic;
    was_read              : in  std_logic;
    recv_data_ready       : out std_logic;
    dout               : out std_logic_vector(7 downto 0));
end component UART;
component UARTClockManager is
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic
 );
end component UARTClockManager;	
signal clk_16x_s : std_logic := '0';
signal recv_s : Word := (others => '0');
signal portReady_s : std_logic := '0';
signal portSending_s : std_logic := '0';
signal done_s : std_logic := '0';
signal rst_s                   : std_logic;
-- This clock should run at 16 times the baud rate.
signal din_s                   : std_logic_vector(7 downto 0) := (others => '0');
signal xmit_buffer_ready_s     : std_logic;
signal xmit_enable_s           : std_logic := '0';
signal was_read_s              : std_logic := '0';
signal recv_data_ready_s       : std_logic;
signal dout_s                  : std_logic_vector(7 downto 0);
begin
recv <= recv_s;
portReady <= portReady_s;
portSending <= portSending_s;
done <= done_s;
UART1 : UART generic map (
    baud_divisor => 25
	 ) port map (
	 clk => clk,
	 rst => rst_s,
	 clk_16x => clk_16x_s,
	 serial_in => serialIn,
	 serial_out => serialOut,
	 din => din_s,
	 xmit_buffer_ready => xmit_buffer_ready_s,
	 xmit_enable => xmit_enable_s,
	 was_read => was_read_s,
	 recv_data_ready => recv_data_ready_s,
	 dout => dout_s
	 );
clockManager : UARTClockManager port map (
	 CLK_IN1 => clk,
	 CLK_OUT1 => clk_16x_s,
	 RESET => '0'
);
process (clk) begin
if rising_edge(clk) then
	if GetOpcode(instruction) = OpcodePort and
	   (GetOperator(instruction) = LoadByteSigned or
		 GetOperator(instruction) = LoadHalfWordSigned or
		 GetOperator(instruction) = LoadByteUnsigned or
		 GetOperator(instruction) = LoadHalfWordUnsigned or
		 GetOperator(instruction) = LoadWord) and
		 getRegisterReferenceB(instruction) = "00001" then
		 
		 if portSending_s = '0' then
		   portReady_s <= recv_data_ready_s;
			if recv_data_ready_s = '1' and CPUReady = '1' then
			  portSending_s <= '1';
			  dout_s <= recv_s;
			  was_read_s <= '1';
			end if;
		 elsif portSending_s = '1' then
			 portSending_s <= '0';
			 portReady_s <= '0';
			 was_read_s <= '0';
			 dout_s <= (others => '0');
		 end if;
   end if;
elsif GetOpcode(instruction) = OpcodePort and
	   (GetOperator(instruction) = StoreByte or
		 GetOperator(instruction) = StoreHalfWord or
		 GetOperator(instruction) = StoreWord) and
		 getRegisterReferenceB(instruction) = "00001" then
		 
		 if done_s = '0' then
			if CPUReady = '1' and xmit_buffer_ready_s = '1' then
			  din_s <= Xmit;
			  done_s <= '1';
			  xmit_enable_s <= '1';
			end if;
		 elsif done_s = '1' then
		   din_s <= (others => '0');
			done_s <= '0';
			xmit_enable_s <= '0';
		 end if;
	end if;
end process;
end Behavioral;

