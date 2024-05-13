library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity keyboard_buf is
  port (
    cpu_clk     : in  std_logic;
    read_addr   : in  std_logic_vector(7 downto 0);
    write_input : in  std_logic_vector(7 downto 0);
    we          : in  std_logic;
    top_ptr     : out std_logic_vector(7 downto 0);
    read_o      : out std_logic_vector(7 downto 0)
  );
end entity;

architecture keyboard_buf_arch of keyboard_buf is
  signal kb_buf_top : std_logic_vector(7 downto 0) := (others => '0');

  signal internal_buf_top         : integer := 0;
  signal internal_read_addr       : integer := 0;
begin
  internal_read_addr <= to_integer(unsigned(read_addr));
  internal_buf_top   <= to_integer(unsigned(kb_buf_top));

  mem: entity work.ram
    generic map (
      DATA_WIDTH => 8,
      ADDR_WIDTH => 8
    )
    port map (
      rclk  => cpu_clk,
      wclk  => cpu_clk,
      raddr => internal_read_addr,
      waddr => internal_buf_top,
      input => write_input,
      we    => we,
      o     => read_o
    );

  process (cpu_clk)
  begin
    if falling_edge(cpu_clk) then
      if we = '1' then
        kb_buf_top <= kb_buf_top + 1;
      end if;
    end if;
  end process;

  top_ptr <= kb_buf_top;
end architecture;
