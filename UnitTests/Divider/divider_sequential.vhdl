library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_std.all;


entity Divider_sequential is
  port (
    Enable    : in  std_logic;
    Ready     : out std_logic;
    CLK       : in  std_logic;
    Overflow  : out std_logic;
    Divisor   : in  std_logic_vector(31 downto 0);
    Dividend  : in  std_logic_vector(31 downto 0);
    Remainder : out std_logic_vector(31 downto 0);
    Quotient  : out std_logic_vector(31 downto 0));
end Divider_sequential;
architecture Behavioral of Divider_sequential is
 signal Enable_S : std_logic := '0';
 signal Ready_S : std_logic := '0';
 signal Overflow_S : std_logic := '0';
 signal Divisor_S : std_logic_vector(31 downto 0) := (others => '0');
 signal Quotient_S : std_logic_vector(31 downto 0) := (others => '0');
 signal Remainder_S : std_logic_vector(63 downto 0) := (others => '0');
 signal Dividend_S : std_logic_vector(31 downto 0) := (others => '0');
 signal is_running : integer := 0;
begin
  Enable_S <= Enable;
  Ready <= Ready_S;
  Overflow <= Overflow_S;
  Divisor_S <= Divisor;
  Quotient <= Quotient_S;
  Remainder <= Remainder_S(63 downto 32);
  Dividend_S <= Dividend;
  Divide: process (CLK)
    variable Remainder_V : std_logic_vector(63 downto 0) := (others => '0');
  begin
    if rising_edge(clk) then
      if Enable_S = '1' then
        if is_running = 0 then
          if Divisor_S = "00000000000000000000000000000000" then
            Ready_S <= '1';
            Overflow_S <= '1';
            Quotient_S <= (others => '0');
            Remainder_S <= (others => '0');
          else
            is_running <= 1;
            Ready_S <= '0';
            Quotient_S <= (others => '0');
            Overflow_S <= '0';
            Remainder_S(63 downto 32) <= (others => '0');
            Remainder_S(31 downto 0) <= Dividend_S;
          end if;
        elsif is_running <= 32 then
          is_running <= is_running + 1;
          Remainder_V := Remainder_S(62 downto 0) & "0";
          Remainder_V(63 downto 32) := std_logic_vector(to_signed(to_integer(signed(Remainder_V(63 downto 32))) - to_integer(signed(Divisor_S)),32));
          if Remainder_V(63) = '1' then
            Remainder_S <= Remainder_S(62 downto 0) & "0";--Remainder_V(63 downto 32) := std_logic_vector(to_unsigned(to_integer(unsigned(Remainder_S(63 downto 32))) + to_integer(unsigned(Divisor_S)),32));
            Quotient_S <= Quotient_S(30 downto 0) & "0";
          else
            Remainder_S <= Remainder_V;
            Quotient_S <= Quotient_S(30 downto 0) & "1";
          end if;
        elsif is_running = 33 then
          is_running <= 0;
          Ready_S <= '1';
        end if;
        
      end if;
    end if;
  end process;
end Behavioral;
    
