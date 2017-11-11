library IEEE;
use IEEE.std_logic_1164.all;
use work.Constants.all;
use IEEE.Numeric_std.all;


entity DividerSequential is
  port (
    Enable    : in  std_logic;
    Ready     : out std_logic;
    CLK       : in  std_logic;
    Overflow  : out std_logic;
    Instruction : in Word;
    Divisor   : in  Word;
    Dividend  : in  Word;
    Remainder : out Word;
    Quotient  : out Word;
    IsSigned  : in  std_logic);

  type machineState is (WaitingToStart,Dividing,Output);
  
end DividerSequential;
architecture Behavioral of DividerSequential is
 signal Enable_S : std_logic := '0';
 signal Ready_S : std_logic := '0';
 signal Overflow_S : std_logic := '0';
 signal Divisor_S : Word := (others => '0');
 signal Quotient_S : Word := (others => '0');
 signal Remainder_S : std_logic_vector(63 downto 0) := (others => '0');
 signal Dividend_S : Word := (others => '0');
 signal is_running : integer := 0;
 signal state : machineState := WaitingToStart;
begin
  Enable_S <= Enable;
  Ready <= Ready_S;
  Overflow <= Overflow_S;
  Divisor_S <= Divisor when (isSigned = '0' or Divisor(31) = '0') else std_logic_vector(-signed(Divisor));
  Quotient <= Quotient_S when (isSigned = '0' or Divisor(31) = Dividend(31)) else std_logic_vector(-signed(Quotient_S));
  Remainder <= Remainder_S(63 downto 32) when (isSigned = '0' or Dividend(31) = '0') else std_logic_vector(-signed(Remainder_S(63 downto 32)));
  Dividend_S <= Dividend when (isSigned = '0' or Dividend(31) = '0') else std_logic_vector(-signed(Dividend));
  
  Divide: process (CLK)
    variable Remainder_V : std_logic_vector(63 downto 0) := (others => '0');
  begin
    if rising_edge(clk) then
      case state is
        when WaitingToStart =>
          if enable_s = '1' then
            if Divisor_S = "00000000000000000000000000000000" then
              state <= Output;
              Ready_S <= '1';
              Overflow_S <= '1';
            else
              state <= Dividing;
              is_running <= 1;
              Ready_S <= '0';
              Quotient_S <= (others => '0');
              Overflow_S <= '0';
              Remainder_S(63 downto 32) <= (others => '0');
              Remainder_S(31 downto 0) <= Dividend_S;
            end if;
          end if;
        when Dividing =>
          if is_running <= 32 then
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
            state <= Output;
          end if;        
        when Output =>
          if enable_s = '1' then
            Ready_S <= '1';
          else
            Ready_S <= '0';
            Overflow_S <= '0';
            State <= WaitingToStart;
          end if;
        when others => null;
      end case;
    end if;
  end process;
end Behavioral;
    
