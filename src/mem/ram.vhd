library ieee;
  use ieee.std_logic_1164.all;

entity ram is

  generic (
    DATA_WIDTH : natural := 16;
    ADDR_WIDTH : natural := 14
  );

  port (
    clk   : in  std_logic;
    addr  : in  natural range 0 to 2 ** ADDR_WIDTH - 1;
    input : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
    we    : in  std_logic := '1';
    o     : out std_logic_vector((DATA_WIDTH - 1) downto 0)
  );
end entity;

architecture rtl of ram is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector((DATA_WIDTH - 1) downto 0);
  type memory_t is array (2 ** ADDR_WIDTH - 1 downto 0) of word_t;

  -- Declare the RAM signal.	
  signal ram : memory_t;

  -- Register to hold the address 
  signal addr_reg : natural range 0 to 2 ** ADDR_WIDTH - 1;

begin

  process (clk)
  begin
    if (rising_edge(clk)) then
      if (we = '1') then
        ram(addr) <= input;
      end if;

      -- Register the address for reading
      addr_reg <= addr;
    end if;
  end process;

  o <= ram(addr_reg);

end architecture;
