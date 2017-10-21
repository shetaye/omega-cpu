library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.Numeric_std.all;

entity divider_TB is
  
end divider_TB;
architecture Behavioral of divider_TB is
  component divider_sequential
    port (
      Enable    : in  std_logic;
      Ready     : out std_logic;
      CLK       : in  std_logic;
      Overflow  : out std_logic;
      Divisor   : in  std_logic_vector(31 downto 0);
      Dividend  : in  std_logic_vector(31 downto 0);
      Remainder : out std_logic_vector(31 downto 0);
      Quotient  : out std_logic_vector(31 downto 0);
      isSigned  : in  std_logic);
  end component;
  signal CLK_S : std_logic;
  signal Enable_S : std_logic := '0';
  signal Ready_S : std_logic;
  signal Overflow_S : std_logic;
  signal Divisor_S : std_logic_vector(31 downto 0);
  signal Quotient_S : std_logic_vector(31 downto 0);
  signal Remainder_S : std_logic_vector(31 downto 0);
  signal Dividend_S : std_logic_vector(31 downto 0);
  signal isSigned_S : std_logic := '1';
  
  signal Stop : std_logic := '0';
begin  -- Behavioral
  uut : divider_sequential port map (
    CLK        => CLK_S,
    Enable     => Enable_S,
    Ready      => Ready_S,
    Overflow   => Overflow_S,
    Divisor    => Divisor_S,
    Quotient   => Quotient_S,
    Remainder  => Remainder_S,
    Dividend   => Dividend_S,
    isSigned   => isSigned_S);
  test: process
    variable dividend_V : integer;
    variable divisor_V : integer;
  begin  -- process
    for dividend_V in 1 to 256 loop
      report "Iteration: Dividend = " & integer'image(dividend_v - 129) severity note;
      for divisor_V in 1 to dividend_V loop
        --report "Iteration: Dividend = " & integer'image(dividend_v - 129) & ", " & "Divisor = " & integer'image(divisor_v - 129) severity note;
        wait until rising_edge(CLK_S);
        Dividend_S <= std_logic_vector(to_signed(dividend_V - 129,32));
        Divisor_S <= std_logic_vector(to_signed(divisor_V - 129,32));
        Enable_S <= '1';
        wait until Ready_S = '1';
        --assert (divisor_V - 129) /= 0 report "error" severity error;
        assert ((divisor_V - 129) /= 0 and Overflow_S = '0') or ((divisor_V - 129) = 0 and Overflow_S = '1') report "Overflow failure" severity error;
        assert Overflow_S = '1' or Dividend_S =
          std_logic_vector(
            to_signed(
              to_integer(signed(Quotient_S)) *
              to_integer(signed(Divisor_S)) +
              to_integer(signed(Remainder_S)),32)) report "Incorrect Answer "&integer'image(to_integer(signed(Dividend_S)))&" / "&integer'image(to_integer(signed(Divisor_S)))&" = "&integer'image(to_integer(signed(Quotient_S)))&" rem "&integer'image(to_integer(signed(Remainder_S))) severity error;
        wait for 10 ns;
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
