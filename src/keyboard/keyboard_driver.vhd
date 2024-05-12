library IEEE;

  use IEEE.STD_LOGIC_1164.all;
  use ieee.numeric_std.all;

  --This code acts as a shift register where the PS/2 keyboard's clock pin acts as the shift clock and the PS/2 data pin acts as the serial data input
  --It shifts the 11-bit scancode into a register then outputs it to the LEDs on the development board

entity keyboard_driver is

  port (
    ps2_dat     : in  STD_LOGIC; -- PS/2 data pin
    ps2_clk     : in  STD_LOGIC; -- PS/2 clock pin
    clock_50    : in  STD_LOGIC; -- 50 MHz system clock
    read_addr   : in  std_logic_vector(7 downto 0);
    buf_top_ptr : out std_logic_vector(7 downto 0);
    read_o      : out std_logic_vector(7 downto 0)
  );

end entity;

architecture keyboard_driver_arch of keyboard_driver is

  signal shift_reg        : STD_LOGIC_VECTOR(10 downto 0) := "00000000000";
  signal shift_reg_sync_1 : std_logic_vector(10 downto 0);
  signal shift_reg_sync_2 : std_logic_vector(10 downto 0);
  signal we_buf           : std_logic                     := '0';

  signal inverted_ps2_clock : STD_LOGIC; -- Inverted PS/2 clock signal

  signal debounced_ps2_clk         : std_logic := '0'; -- PS/2 clock debouncer
  signal delay_1, delay_2, delay_3 : std_logic := '0';

  signal counter        : natural := 0; -- 3 stage synchronizer
  signal counter_sync_1 : natural := 0;
  signal counter_sync_2 : natural := 0;

begin
  buf: entity work.keyboard_buf
    port map (
      ps2_clk     => inverted_ps2_clock, -- make writing happen on falling edge of cpu_clk
      cpu_clk     => clock_50,
      read_addr   => read_addr,
      write_input => shift_reg_sync_2(9 downto 2),
      we          => we_buf,
      top_ptr     => buf_top_ptr,
      read_o      => read_o
    );

  process (clock_50)
  begin
    if rising_edge(clock_50) then
      delay_1 <= ps2_clk;
      delay_2 <= delay_1;
      delay_3 <= delay_2;
    end if;
  end process;

  debounced_ps2_clk  <= delay_1 and delay_2 and delay_3;
  inverted_ps2_clock <= not debounced_ps2_clk; -- Invert the PS/2 clock signal

  process (inverted_ps2_clock)
  begin
    if rising_edge(inverted_ps2_clock) then
      shift_reg(9 downto 0) <= shift_reg(10 downto 1);
      shift_reg(10) <= ps2_dat;
      counter <= counter + 1;
      if counter >= 10 then
        counter <= 0;
      end if;
    end if;
  end process;

  process (clock_50)
  begin
    if rising_edge(clock_50) then
      counter_sync_1 <= counter;
      counter_sync_2 <= counter_sync_1;
      shift_reg_sync_1 <= shift_reg;
      shift_reg_sync_2 <= shift_reg_sync_1;
      if counter_sync_2 >= 10 then
        we_buf <= '1';
      else
        we_buf <= '0';
      end if;
    end if;
  end process;
end architecture;
