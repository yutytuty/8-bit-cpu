library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity rom is

  port (
    clk  : in  std_logic;
    addr : in  std_logic_vector(15 downto 0);
    o    : out std_logic_vector(7 downto 0));
end entity;

architecture rom_arch of rom is
  constant ROM_START  : natural := 0; -- mapped location of rom
  constant ROM_HEIGHT : natural := 32768;
  constant ROM_WIDTH  : natural := 8;
  subtype word_t is std_logic_vector((ROM_WIDTH - 1) downto 0);
  type memory_t is array (0 to ROM_HEIGHT - 1) of word_t;

  constant rom : memory_t := (
    -- some example values
    0      => x"01",
    1      => x"A0",
    2      => x"55",
    3      => x"AA",
    others => x"00"
  );
  signal addr_reg : natural range 0 to 2 ** ROM_WIDTH - 1;
begin
  process (clk)
  begin
    if rising_edge(clk) then

      if to_integer(unsigned(addr)) >= ROM_START and to_integer(unsigned(addr)) < ROM_START + ROM_HEIGHT then
        addr_reg <= to_integer(unsigned(addr)) - ROM_START;
      end if;
    end if;
  end process;

  o <= rom(addr_reg);
end architecture;
