library ieee;
  use ieee.std_logic_1164.all;

entity ram is

  generic (
    DATA_WIDTH : natural := 16;
    ADDR_WIDTH : natural := 14
  );

  port (
    rclk, wclk   : in  std_logic;
    raddr, waddr : in  natural range 0 to 2 ** ADDR_WIDTH - 1;
    input        : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
    we           : in  std_logic := '1';
    o            : out std_logic_vector((DATA_WIDTH - 1) downto 0)
  );
end entity;

architecture rtl of ram is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector((DATA_WIDTH - 1) downto 0);
  type memory_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

  -- Declare the RAM signal.	
  signal mem : memory_t := (
    others => (others => '0')
  );
begin
  process (wclk)
  begin
    if (rising_edge(wclk)) then
      if (we = '1') then
        mem(waddr) <= input;
      end if;
    end if;
  end process;

  process (rclk)
  begin
    if rising_edge(rclk) then
      o <= mem(raddr);
    end if;
  end process;
end architecture;
