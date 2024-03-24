library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity ram is
  port (
    clk   : in  std_logic;
    addr  : in  std_logic_vector(15 downto 0);
    we    : in  std_logic;
    input : in  std_logic_vector(15 downto 0);
    o     : out std_logic_vector(15 downto 0));
end entity;

architecture ram_arch of ram is
  -- 32768
  constant RAM_START  : natural := 32768; -- mapped location of ram
  constant RAM_HEIGHT : natural := 32768;
  constant RAM_WIDTH  : natural := 16;
  subtype word_t is std_logic_vector((RAM_WIDTH - 1) downto 0);
  type memory_t is array (0 to RAM_HEIGHT - 1) of word_t;

  signal ram      : memory_t := (
    -- some example values
    0      => x"0001",
    1      => x"00A0",
    2      => x"0055",
    3      => x"00AA",
    others => x"0000"
  );
  signal addr_reg : natural range 0 to RAM_HEIGHT - 1;
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if to_integer(unsigned(addr)) >= RAM_START and to_integer(unsigned(addr)) < RAM_START + RAM_HEIGHT - 1 then
        if we = '1' then
          ram(addr_reg) <= input;
        end if;
        addr_reg <= to_integer(unsigned(addr)) - RAM_START;
      end if;
    end if;
  end process;

  o <= ram(addr_reg);
end architecture;
