library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity MEM_stage is
  port (
    clk                : in  std_logic;
    mem_instruction    : in  std_logic; -- is the current instruction an instruction that acecsses memory?
    we                 : in  std_logic;
    data_in            : in  std_logic_vector(15 downto 0);
    address            : in  std_logic_vector(15 downto 0);
    wb_reg             : in  natural range 0 to 7;
    wb_we              : in  std_logic;
    -- keyboard
    kbd_driver_out     : in  std_logic_vector(7 downto 0);
    kbd_buf_top_offset : in  std_logic_vector(7 downto 0);
    kbd_driver_raddr   : out std_logic_vector(7 downto 0);
    -----------
    wb_reg_o           : out natural range 0 to 7;
    wb_we_o            : out std_logic;
    o                  : out std_logic_vector(15 downto 0));
end entity;

architecture MEM_stage_arch of MEM_stage is

  constant DATA_START : natural := 16#4000#;

  constant KEYBOARD_START   : natural := 16#6e60#;
  constant KEYBOARD_TOP_PTR : natural := KEYBOARD_START - 1;
  constant KEYBOARD_END     : natural := KEYBOARD_START + 16#100#;

  constant VIDEO_START : natural := KEYBOARD_END;
  constant VIDEO_END   : natural := VIDEO_START + 16#fa0#;

  constant STACK_START : natural := VIDEO_END;
  constant STACK_END   : natural := STACK_START + 16#100#;

  signal mem_o   : std_logic_vector(15 downto 0);
  signal mem_clk : std_logic := '0';

  signal internal_we   : std_logic := '0';
  signal internal_addr : natural   := 0;

  signal keyboard_offset : std_logic_vector(15 downto 0); -- addr - keyboard_start
begin
  mem_clk         <= not clk;
  internal_we     <= we and mem_instruction;
  internal_addr   <= to_integer(unsigned(address(13 downto 0)));
  keyboard_offset <= address - KEYBOARD_START;

  process (keyboard_offset)
  begin
    if address >= KEYBOARD_START and address < KEYBOARD_END then
      kbd_driver_raddr <= keyboard_offset(7 downto 0);
    else
      kbd_driver_raddr <= (others => '0');
    end if;
  end process;

  mem: entity work.ram
    port map (
      rclk  => mem_clk,
      wclk  => mem_clk,
      raddr => internal_addr,
      waddr => internal_addr,
      we    => internal_we,
      input => data_in,
      o     => mem_o
    );

  process (clk)
    variable tmp : std_logic_vector(15 downto 0);
  begin
    tmp := (others => '0');
    if rising_edge(clk) then
      if mem_instruction = '0' then
        o <= address; -- meaning the output of the alu was not for the MEM stage.
      else
        if address >= DATA_START and address < KEYBOARD_TOP_PTR then
          o <= mem_o;
        elsif address >= KEYBOARD_TOP_PTR and address < KEYBOARD_START then
          tmp(7 downto 0) := kbd_buf_top_offset;
          tmp(15 downto 8) := (others => '0');
          o <= tmp + KEYBOARD_START;
        elsif address >= KEYBOARD_START and address < KEYBOARD_END then
          o(7 downto 0) <= kbd_driver_out;
          o(15 downto 8) <= (others => '0');
        elsif address >= VIDEO_START and address < STACK_END then
          o <= mem_o;
        else
          o <= (others => '0');
        end if;
      end if;

      if we = '1' and mem_instruction = '1' then
        wb_we_o <= '0'; -- means instruction was ST, so no write to registers
      elsif we = '0' and mem_instruction = '1' then
        wb_we_o <= '1'; -- ld, so write to registers
      else
        wb_we_o <= wb_we; -- not memory instruction, keep as is.
      end if;
      wb_reg_o <= wb_reg;
    end if;
  end process;
end architecture;
