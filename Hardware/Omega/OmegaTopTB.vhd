--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:44:52 10/01/2016
-- Design Name:   
-- Module Name:   /home/student1/Documents/Omega/CPU/Hardware/Omega/OmegaTopTB.vhd
-- Project Name:  Omega
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: OmegaTop
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;

library work;
use work.Constants.ALL;
 
ENTITY OmegaTopTB IS
END OmegaTopTB;
 
ARCHITECTURE behavior OF OmegaTopTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT OmegaTop
    PORT(
         CLK : IN  std_logic;
         RX : IN  std_logic;
         TX : OUT  std_logic;
			LEDS : out std_logic_vector(7 downto 0);
			SRAM_addr     : out std_logic_vector(20 downto 0);
			SRAM_OE       : out std_logic;
			SRAM_CE       : out std_logic;
			SRAM_WE       : out std_logic;
			SRAM_data     : inout  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RX : std_logic := '0';


 	--Outputs
   signal TX : std_logic;
	signal LEDS : std_logic_vector(7 downto 0);
   signal SRAM_addr : std_logic_vector(20 downto 0);
   signal SRAM_OE : std_logic;
   signal SRAM_CE : std_logic;
   signal SRAM_WE : std_logic;
	signal SRAM_data : std_logic_vector(7 downto 0);
	signal memory : MemoryArray := (others => (others => '0'));
   -- Clock period definitions
   constant CLK_period : time := 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: OmegaTop PORT MAP (
          CLK => CLK,
          RX => RX,
          TX => TX,
			 LEDS => LEDS,
			 SRAM_addr => SRAM_addr,
			 SRAM_OE => SRAM_OE,
			 SRAM_CE => SRAM_CE,
			 SRAM_WE => SRAM_WE,
			 SRAM_data => SRAM_data
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
	read_proc: process(SRAM_oe,SRAM_addr)
   begin
	   if SRAM_oe = '1' then
			sram_data <= (others => 'Z');
		else
			sram_data <= memory(to_integer(unsigned(SRAM_ADDR)));
		end if;
	end process read_proc;
 
	write_proc: process(SRAM_we,SRAM_addr)
	begin
		if SRAM_we = '0' then
			memory(to_integer(unsigned(SRAM_ADDR))) <= sram_data;
		end if;
	end process write_proc;
	
   -- Stimulus process

--   stim_proc: process
--   begin		
--      -- hold reset state for 100 ns.
--      wait for 100 ns;	
--
--      wait for CLK_period*10;
--
--      -- insert stimulus here 
--
--      wait;
--   end process;

END;
