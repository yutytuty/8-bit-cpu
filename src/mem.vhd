library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

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
      clk      : in  std_logic;
      addr_bus : in  std_logic_vector(15 downto 0);
      o        : out std_logic_vector(7 downto 0));
  end component;

  component ram is
    port (
      clk      : in  std_logic;
      addr_bus : in  std_logic_vector(15 downto 0);
      load     : in  std_logic;
      input    : in  std_logic_vector(7 downto 0);
      o        : out std_logic_vector(7 downto 0));
  end component;

  component mem_selector is
    port (
      rom      : in  std_logic_vector(7 downto 0);
      ram      : in  std_logic_vector(7 downto 0);
      addr_bus : in  std_logic_vector(15 downto 0);
      o        : out std_Logic_vector(7 downto 0));
  end component;

  signal rom_out, ram_out : std_logic_vector(7 downto 0);
begin
  c_ROM: rom
    port map (
      clk      => clk,
      addr_bus => addr_bus,
      o        => rom_out
    );

  c_RAM: ram
    port map (
      clk      => clk,
      addr_bus => addr_bus,
      load     => ram_load,
      input    => input,
      o        => ram_out
    );

  c_MEM_SELECTOR: mem_selector
    port map (
      rom      => rom_out,
      ram      => ram_out,
      addr_bus => addr_bus,
      o        => o
    );
end architecture;
