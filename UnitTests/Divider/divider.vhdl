library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_std.all;


entity Divider is
  port (
    Enable    : in  std_logic;
    Ready     : out std_logic;
    CLK       : in  std_logic;
    Overflow  : out std_logic;
    Divisor   : in  std_logic_vector(31 downto 0);
    Dividend  : in  std_logic_vector(31 downto 0);
    Remainder : out std_logic_vector(31 downto 0);
    Quotient  : out std_logic_vector(31 downto 0));
end Divider;
architecture Behavioral of Divider is
 signal Enable_S : std_logic;
 signal Ready_S : std_logic;
 signal Overflow_S : std_logic;
 signal Divisor_S : std_logic_vector(31 downto 0);
 signal Quotient_S : std_logic_vector(31 downto 0);
 signal Remainder_S : std_logic_vector(31 downto 0);
 signal Dividend_S : std_logic_vector(31 downto 0);
begin
  Enable_S <= Enable;
  Ready <= Ready_S;
  Overflow <= Overflow_S;
  Divisor_S <= Divisor;
  Quotient <= Quotient_S;
  Remainder <= Remainder_S;
  Dividend_S <= Dividend;
  Divide: process (CLK)
  begin  -- process Divide
    if rising_edge(CLK) then
      if Enable_S = '1' then
        if Divisor_S = "00000000000000000000000000000000" then
          Ready <= '1';
          Overflow_S <= '1';
          Quotient_S <= (others => '0');
          Remainder_S <= (others => '0');
        else
          Quotient_S <= std_logic_vector(unsigned(Dividend_S) / unsigned(Divisor_S));
          Remainder_S <= std_logic_vector(unsigned(Dividend_S) rem unsigned(Divisor_S));
          Ready_S <= '1';
          Overflow_S <= '0';
        end if;
      else
        Ready_S <= '0';
        Overflow_S <= '0';
        Quotient_S <= (others => '0');
        Remainder_S <= (others => '0');
      end if;
    end if;
  end process; 
 
end Behavioral;
