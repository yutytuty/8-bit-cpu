library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity MEM_stage is
  port (
    clk             : in  std_logic;
    mem_instruction : in  std_logic; -- is the current instruction an instruction that acecsses memory?
    we              : in  std_logic;
    data_in         : in  std_logic_vector(15 downto 0);
    address         : in  std_logic_vector(15 downto 0);
    wb_reg          : in  natural range 0 to 7;
    wb_we           : in  std_logic;
    wb_reg_o        : out natural range 0 to 7;
    wb_we_o         : out std_logic;
    o               : out std_logic_vector(15 downto 0));
end entity;

architecture MEM_stage_arch of MEM_stage is

  signal mem_o   : std_logic_vector(15 downto 0);
  signal mem_clk : std_logic := '0';

  signal internal_we : std_logic := '0';
  signal internal_addr : natural := 0;

begin
  mem_clk     <= not clk;
  internal_we <= we and mem_instruction;
  internal_addr <= to_integer(unsigned(address(13 downto 0)));

  mem: entity work.ram
    port map (
      clk   => mem_clk,
      addr  => internal_addr,
      we    => internal_we,
      input => data_in,
      o     => mem_o
    );

  process (clk)
  begin
    if rising_edge(clk) then
      if mem_instruction = '0' then
        o <= address; -- meaning the output of the alu was not for the MEM stage.
      else
        o <= mem_o; -- meaning instruction was LD.
      end if;

      if we = '1' and mem_instruction = '1' then
        wb_we_o <= '0'; -- means instruction was ST, so no write to registers
      elsif we = '0' and mem_instruction = '1' then
        wb_we_o <= '1';
      else
        wb_we_o <= wb_we;
      end if;
      wb_reg_o <= wb_reg;
    end if;
  end process;
end architecture;
