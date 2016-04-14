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
entity PortController is
  port (
    CLK  : in std_logic;
    XMit : in Word;
    Recv : out Word;
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
signal clk                   : in  std_logic;
signal rst                   : in  std_logic;
-- This clock should run at 16 times the baud rate.
signal clk_16x               : in  std_logic;
signal serial_out            : out std_logic;
signal serial_in             : in  std_logic;
signal din                   : in  std_logic_vector(7 downto 0);
signal xmit_buffer_ready     : out std_logic;
signal xmit_enable           : in  std_logic;
signal was_read              : in  std_logic;
signal recv_data_ready       : out std_logic;
signal dout                  : out std_logic_vector(7 downto 0));
begin
recv <= recv_s;
portReady <= portReady_s;
portSending <= portSending_s;
done <= done_s;
UART1 : UART generic map (
    baud_divisor => 25
	 ) port map (
	 );
clockManager : UARTClockManager port map (
	 CLK_IN1 => clk,
	 CLK_OUT1 => clk_16x_s,
	 RESET => '0'
);

end Behavioral;
