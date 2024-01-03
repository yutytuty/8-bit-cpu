library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity mem is
  port (
    clk      : in  std_logic;
    addr_bus : in  std_logic_vector(15 downto 0);
    ram_load : in  std_logic;
    input    : in  std_logic_vector(7 downto 0);
    o        : out std_logic_vector(7 downto 0));
end entity;

architecture mem_arch of mem is
  component rom is
    port (
      clk  : in  std_logic;
      addr : in  std_logic_vector(15 downto 0);
      o    : out std_logic_vector(7 downto 0));
  end component;

  component ram is
    port (
      clk   : in  std_logic;
      addr  : in  std_logic_vector(15 downto 0);
      we    : in  std_logic;
      input : in  std_logic_vector(7 downto 0);
      o     : out std_logic_vector(7 downto 0));
  end component;

  signal rom_out, ram_out : std_logic_vector(7 downto 0);
begin
  c_ROM: rom
    port map (
      clk  => clk,
      addr => addr_bus,
      o    => rom_out
    );

  c_RAM: ram
    port map (
      clk   => clk,
      addr  => addr_bus,
      we    => ram_load,
      input => input,
      o     => ram_out
    );

  process (addr_bus, ram_out, rom_out)
  begin
    if to_integer(unsigned(addr_bus)) >= 0 and to_integer(unsigned(addr_bus)) < 32768 then
      o <= rom_out;
    elsif to_integer(unsigned(addr_bus)) >= 32768 and to_integer(unsigned(addr_bus)) < 65536 then
      o <= ram_out;
    else
      o <= (others => '0');
    end if;
  end process;
end architecture;
