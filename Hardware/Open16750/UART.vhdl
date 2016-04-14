--************************************************************************
--
-- Copyright (C) August Schwerdfeger
-- September 30, 2015
--
--************************************************************************
--  This program is free software: you can redistribute it and/or modify--
--  it under the terms of the GNU Lesser General Public License as      --
--  published by the Free Software Foundation, either version 3 of the  --
--  License, or (at your option) any later version.                     --
--                                                                      --
--  This program is distributed in the hope that it will be useful,     --
--  but WITHOUT ANY WARRANTY; without even the implied warranty of      --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       --
--  GNU Lesser General Public License <http://www.gnu.org/licenses/>    --
--  for more details.                                                   --
--************************************************************************
--
-- This circuit serves as a simplifying wrapper to the 'uart_16750' UART
-- core available on OpenCores.org.

-- It provides a hard-wired generic interface to set the word length, parity,
-- and stop bit count. Upon initialization it will enable and reset the
-- UART's receive and transmit FIFOs, and configure the interrupts such that
-- a signal is received iff the receive FIFO is non-empty.

-- It places the UART behind the following interface:
-- * When a byte is received, it is output on 'dout' and 'recv_data_ready'
--   goes high.
-- * Setting 'was_read' high signals that this byte has been read and the
--   next one in the FIFO can be advanced.
-- * Receiving bytes takes priority over transmitting. When the circuit is
--   ready to transmit a byte, 'xmit_buffer_ready' goes high.
-- * Setting 'xmit_enable' high queues the byte on 'din' for transmission.
-- * If the transmit FIFO is full, this byte will be discarded silently;
--   no error state from the UART is conveyed out of the circuit.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART is
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
end UART;

architecture Behavioral of UART is

  component uart_16750 is
    port (
      CLK         : in std_logic;                             -- Clock
      RST         : in std_logic;                             -- Reset
      BAUDCE      : in std_logic;                             -- Baudrate generator clock enable
      CS          : in std_logic;                             -- Chip select
      WR          : in std_logic;                             -- Write to UART
      RD          : in std_logic;                             -- Read from UART
      A           : in std_logic_vector(2 downto 0);          -- Register select
      DIN         : in std_logic_vector(7 downto 0);          -- Data bus input
      DOUT        : out std_logic_vector(7 downto 0);         -- Data bus output
      DDIS        : out std_logic;                            -- Driver disable
      INT         : out std_logic;                            -- Interrupt output
      OUT1N       : out std_logic;                            -- Output 1
      OUT2N       : out std_logic;                            -- Output 2
      RCLK        : in std_logic;                             -- Receiver clock (16x baudrate)
      BAUDOUTN    : out std_logic;                            -- Baudrate generator output (16x baudrate)
      RTSN        : out std_logic;                            -- RTS output
      DTRN        : out std_logic;                            -- DTR output
      CTSN        : in std_logic;                             -- CTS input
      DSRN        : in std_logic;                             -- DSR input
      DCDN        : in std_logic;                             -- DCD input
      RIN         : in std_logic;                             -- RI input
      SIN         : in std_logic;                             -- Receiver input
      SOUT        : out std_logic                             -- Transmitter output
      );
  end component uart_16750;

  type init_stages is (start,open_divisor_latch,set_baud_divisor_lsb,set_baud_divisor_msb,close_divisor_latch,set_trigger_levels,set_interrupts,waiting,reading,writing);
  
  type write_stages is (write_set_addr, write_enable, write_end);
  type read_stages is (read_set_addr, read_enable, read_get_data, read_end);

  signal init_stage : init_stages := start;
  signal write_stage : write_stages := write_set_addr;
  signal read_stage : read_stages := read_set_addr;
  
  signal data_in_s : std_logic_vector(7 downto 0) := (others => '0');
  signal uart_dout : std_logic_vector(7 downto 0) := (others => '0');
  signal data_out_s : std_logic_vector(7 downto 0) := (others => '0');
  signal data_out_waiting : std_logic := '0';

  signal recv_data_ready_s : std_logic := '0';
  signal xmit_buffer_ready_s : std_logic := '0';
  
  signal rst_s : std_logic := '0';
  signal CS_s : std_logic := '0';
  signal WR_s : std_logic := '0';
  signal RD_s : std_logic := '0';
  signal baudout_s : std_logic := '1';
  
  signal addr_s : std_logic_vector(2 downto 0) := "000";
  
  signal CTS_s : std_logic := '1';
  signal DSR_s : std_logic := '1';
  signal DTR_s : std_logic;
  signal RTS_s : std_logic;

  signal IRQ_s : std_logic;

  constant baud_divisor_c : std_logic_vector(15 downto 0) := std_logic_vector(to_unsigned(baud_divisor,16));

begin

  uart_wrapped: uart_16750 port map (
                                CLK     => clk,
                                RST     => rst,
                                BAUDCE  => clk_16x,
                                CS      => CS_s,
                                WR      => WR_s,
                                RD      => RD_s,
                                A       => ADDR_s,
                                DIN     => data_in_s,
                                DOUT    => uart_dout,
                                DDIS    => OPEN,
                                INT     => IRQ_s,
                                OUT1N   => OPEN,
                                OUT2N   => OPEN,
                                RCLK    => baudout_s,
                                BAUDOUTN=> baudout_s,
                                RTSN    => RTS_s,
                                DTRN    => DTR_s,
                                CTSN    => '1',
                                DSRN    => '1',
                                DCDN    => '1',
                                RIN     => '1',
                                SIN     => serial_in,
                                SOUT    => serial_out
                             );
  
  dout <= data_out_s;
  recv_data_ready <= recv_data_ready_s;
  xmit_buffer_ready <= xmit_buffer_ready_s;
  
  init: process (clk, rst)
    function LCR_lower_7 return std_logic_vector is
      variable rv : std_logic_vector(6 downto 0) := "0000000";
    begin
      rv(6 downto 5) := "00";
      if parity_is_even then
        rv(4) := '1';
      else
        rv(4) := '0';
      end if;
      if has_parity then
        rv(3) := '1';
      else
        rv(3) := '0';
      end if;
      if stop_bits = 2 then
        rv(2) := '1';
      else
        rv(2) := '0';
      end if;
      rv(1 downto 0) := std_logic_vector(to_unsigned(word_length - 5,2));
      return rv;
    end function LCR_lower_7;
    procedure uart_read(addr  : in std_logic_vector(2 downto 0)) is
      -- To effect a read from the UART:
      -- 1. Set the address of the register to read from and set CS.
      -- 2. Wait one clock cycle.
      -- 3. Set RD.
      -- 4. Wait one clock cycle.
      -- 5. Read the data from DOUT and clear CS and RD.
    begin
      case read_stage is
        when read_set_addr =>
          ADDR_s <= addr;
          CS_s <= '1';
          read_stage <= read_enable;
        when read_enable =>
          RD_s <= '1';
          read_stage <= read_get_data;
        when read_get_data =>
          data_out_waiting <= '1';
          data_out_s <= uart_dout;
          read_stage <= read_end;
        when read_end =>
          CS_s <= '0';
          RD_s <= '0';
        when others => null;
      end case;
    end procedure uart_read;

    procedure uart_write(addr  : in std_logic_vector(2 downto 0);
                         data  : in std_logic_vector(7 downto 0)) is
      -- To effect a write to the UART:
      -- 1. Set the address of the register to read from, put the data to write
      --    on DIN (to persist for at least 2 clock cycles), and set CS.
      -- 2. Wait one clock cycle.
      -- 3. Set WR.
      -- 4. Wait one clock cycle.
      -- 5. Clear CS and WR.
    begin
      case write_stage is
        when write_set_addr =>
          ADDR_s <= addr;
          data_in_s <= data;
          CS_s <= '1';
          write_stage <= write_enable;
        when write_enable =>
          WR_s <= '1';
          write_stage <= write_end;
        when write_end =>
          CS_s <= '0';
          WR_s <= '0';
          data_in_s <= (others => '0');
        when others => null;
      end case;
    end procedure uart_write;
  begin  -- process init
    if rst = '1' then
      rst_s <= '1';
      init_stage <= start;
      xmit_buffer_ready_s <= '0';
      recv_data_ready_s <= '0';
    elsif falling_edge(clk) then
      case init_stage is
        when start =>
          rst_s <= '1';
          xmit_buffer_ready_s <= '0';
          recv_data_ready_s <= '0';
          init_stage <= open_divisor_latch;
        when open_divisor_latch =>
          rst_s <= '0';
          -- Set line control register (LCR) to enable setting the baud
          -- divisor.
          uart_write("011","10000000");
          if write_stage = write_end then
            write_stage <= write_set_addr;
            init_stage <= set_baud_divisor_lsb;
          end if;
        when set_baud_divisor_lsb =>
          -- Set divisor latch LSB (DLL). Default: "00000001"
          uart_write("000",baud_divisor_c(7 downto 0));
          if write_stage = write_end then
            write_stage <= write_set_addr;
            init_stage <= set_baud_divisor_msb;
          end if;
        when set_baud_divisor_msb =>
          -- Set divisor latch MSB (DLM). Default: "00000000"
          uart_write("001","00000000");
          if write_stage = write_end then
              write_stage <= write_set_addr;
              init_stage <= close_divisor_latch;              
          end if;
        when close_divisor_latch =>
          -- Set line control register (LCR) to disable setting the baud
          -- divisor, and to set the word length, parity, and stop bit
          -- configuration to the proper values.
          uart_write("011","0" & LCR_lower_7);
          if write_stage = write_end then
            write_stage <= write_set_addr;
            init_stage <= set_trigger_levels;
          end if;
        when set_trigger_levels =>
          -- Set FIFO control register (FCR) to enable and reset the FIFOs.
          uart_write("010","00000111");
          if write_stage = write_end then
              write_stage <= write_set_addr;
              init_stage <= set_interrupts;
          end if;
        when set_interrupts =>
          -- Set interrupt enable register (IER) to disable all interrupts
          -- except "Received Data Available."
          uart_write("001","00000001");
          if write_stage = write_end then
              write_stage <= write_set_addr;
              init_stage <= waiting;
          end if;
        when waiting =>
          ADDR_s <= "000";
          -- If the FIFO has a byte available and the local buffer is
          -- empty, put the byte in the local buffer.
          if data_out_waiting = '0' and IRQ_s = '1' then
            init_stage <= reading;
            data_in_s <= (others => '0');
            xmit_buffer_ready_s <= '0';
            recv_data_ready_s <= '0';
          -- If the local buffer is full and 'was_read' is high,
          -- empty the buffer.
          elsif data_out_waiting <= '1' and was_read = '1' then
            data_out_waiting <= '0';
            recv_data_ready_s <= '0';
            data_in_s <= (others => '0');
          -- If no read activity is occurring and 'xmit_enable'
          -- is high, queue DIN for transmission.
          elsif was_read = '0' and xmit_enable = '1' then
            init_stage <= writing;
            data_in_s <= din;
            recv_data_ready_s <= '0';
            xmit_buffer_ready_s <= '0';
          else
            recv_data_ready_s <= data_out_waiting;
            xmit_buffer_ready_s <= '1';
            data_in_s <= (others => '0');
            if data_out_waiting = '0' then
              data_out_s <= (others => '0');
            end if;
          end if;
        when reading =>
          uart_read("000");
          if read_stage = read_end then
            if was_read = '0' then
              read_stage <= read_set_addr;
              init_stage <= waiting;
            end if;
          end if;
        when writing =>
          uart_write("000",data_in_s);
          if write_stage = write_end and xmit_enable = '0' then
            data_in_s <= (others => '0');
            write_stage <= write_set_addr;
            init_stage <= waiting;
          end if;
        when others => null;
      end case;
    end if;
  end process init;   
  
  
end Behavioral;
