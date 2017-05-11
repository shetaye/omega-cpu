library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_std.all;

entity divider_TB is
  
end divider_TB;
architecture Behavioral of divider_TB is
  component divider
    port (
      Enable    : in  std_logic;
      Ready     : out std_logic;
      CLK       : in  std_logic;
      Overflow  : out std_logic;
      Divisor   : in  std_logic_vector(31 downto 0);
      Dividend  : in  std_logic_vector(31 downto 0);
      Remainder : out std_logic_vector(31 downto 0);
      Quotient  : out std_logic_vector(31 downto 0));
  end component;
  signal CLK_S : std_logic;
  signal Enable_S : std_logic;
  signal Ready_S : std_logic;
  signal Overflow_S : std_logic;
  signal Divisor_S : std_logic_vector(31 downto 0);
  signal Quotient_S : std_logic_vector(31 downto 0);
  signal Remainder_S : std_logic_vector(31 downto 0);
  signal Dividend_S : std_logic_vector(31 downto 0);

  signal Stop : std_logic := '0';
begin  -- Behavioral
  uut : divider port map (
    CLK        => CLK_S,
    Enable     => Enable_S,
    Ready      => Ready_S,
    Overflow   => Overflow_S,
    Divisor    => Divisor_S,
    Quotient   => Quotient_S,
    Remainder  => Remainder_S,
    Dividend => Dividend_S);
  test: process
    variable dividend_V : integer;
    variable divisor_V : integer;
  begin  -- process
    for dividend_V in 0 to 65535 loop
      report "Iteration" severity note;
      for divisor_V in 0 to dividend_V loop
        wait until rising_edge(CLK_S);
        Dividend_S <= std_logic_vector(to_unsigned(dividend_V,32));
        Divisor_S <= std_logic_vector(to_unsigned(divisor_V,32));
        Enable_S <= '1';
        wait until Ready_S = '1';
        assert (divisor_V /= 0 and Overflow_S = '0') or (divisor_V = 0 and Overflow_S = '1') report "Overflow failure" severity error;
        assert Dividend_S = std_logic_vector(unsigned(Quotient_S) * unsigned(Divisor_S) + unsigned(Remainder_S)) report "Incorrect Answer" severity error;
        Enable_S <= '0';
      end loop;  -- divisor
    end loop;  -- dividend
    Stop <= '1';
    wait;
  end process;
  clock: process
  begin
    CLK_S <= '0';
    wait for 10 ns;
    CLK_S <= '1';
    wait for 10 ns;
    if Stop = '1' then
      wait;
    end if;
  end process;
  

end Behavioral;
