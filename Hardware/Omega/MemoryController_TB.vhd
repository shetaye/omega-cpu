--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:29:38 11/03/2016
-- Design Name:   
-- Module Name:   /home/student1/Documents/Omega/CPU/Hardware/Omega/MemoryController_TB.vhd
-- Project Name:  Omega
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MemoryController
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
--USE ieee.numeric_std.ALL;
 
ENTITY MemoryController_TB IS
END MemoryController_TB;
 
ARCHITECTURE behavior OF MemoryController_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MemoryController
    PORT(
         CLK : IN  std_logic;
         Address : IN  std_logic_vector(31 downto 0);
         Enable : IN  std_logic;
         ToWrite : IN  std_logic_vector(31 downto 0);
         FromRead : OUT  std_logic_vector(31 downto 0);
         Instruction : IN  std_logic_vector(31 downto 0);
         Reset : IN  std_logic;
         Done : OUT  std_logic;
         SRAM_addr : OUT  std_logic_vector(20 downto 0);
         SRAM_OE : OUT  std_logic;
         SRAM_CE : OUT  std_logic;
         SRAM_WE : OUT  std_logic;
         SRAM_data : INOUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal Address : std_logic_vector(31 downto 0) := (others => '0');
   signal Enable : std_logic := '0';
   signal ToWrite : std_logic_vector(31 downto 0) := (others => '0');
   signal Instruction : std_logic_vector(31 downto 0) := (others => '0');
   signal Reset : std_logic := '0';

	--BiDirs
   signal SRAM_data : std_logic_vector(7 downto 0);

 	--Outputs
   signal FromRead : std_logic_vector(31 downto 0);
   signal Done : std_logic;
   signal SRAM_addr : std_logic_vector(20 downto 0);
   signal SRAM_OE : std_logic;
   signal SRAM_CE : std_logic;
   signal SRAM_WE : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 31.25 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MemoryController PORT MAP (
          CLK => CLK,
          Address => Address,
          Enable => Enable,
          ToWrite => ToWrite,
          FromRead => FromRead,
          Instruction => Instruction,
          Reset => Reset,
          Done => Done,
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

   data_proc: process
   begin
	   sram_data <= (others => 'Z');
	   wait until falling_edge(SRAM_oe);
		sram_data <= "00000000";
	   wait for 9 ns;
	   sram_data <= "01011010";
		wait until SRAM_oe = '1';
	end process data_proc;
		

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait until SRAM_we = '1';
		
		wait for CLK_period*10;
		 
		enable <= '1'; 
		instruction <= "00010000000000000000000000000000";
		address <= "00000000000000000000000000000100";

      wait until done = '1';
		
		enable <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
