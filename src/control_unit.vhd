library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity control_unit is
  port (
    clk                   : in  std_logic;
    inst                  : in  std_logic_vector(7 downto 0);
    opts                  : in  std_logic_vector(2 downto 0);
    rst                   : in  std_logic;

    -- registers
    reg_oe_sel            : out natural range 0 to 7; -- selects which register is output to data bus
    reg_we                : out std_logic;            -- is any register getting written to
    reg_we_sel            : out natural range 0 to 7; -- select which register to write to
    data_bus_selector_sel : out natural range 0 to 2; -- register, alu or mem
    -- alu
    add_sub               : out std_logic;            -- add or subtract in alu
    alu_selector_sel      : out natural range 0 to 7; -- select which register is input to alu
    -- IR/OPTS
    ir_load               : out std_logic;
    opts_load             : out std_logic;
    -- address bus
    addr_bus_sel          : out natural range 0 to 1;
    -- PC
    pc_inc                : out std_logic;
    -- memory
    ram_load              : out std_logic);
end entity;

architecture control_unit_arch of control_unit is
  type state_type is (
      S_FETCH_0,
      S_DECODE_0,
      S_MOV_0,
      S_MOV_1,
      S_ADD_0,
      S_ADD_1,
      S_ADD_2,
      S_INC_PC_0
    );

  signal current_state, next_state : state_type;
begin

  p_current_state: process (clk, rst)
  begin
    if rst = '1' then
      current_state <= S_FETCH_0;
    end if;
    if rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;

  p_next_state: process (current_state, inst)
  begin
    case current_state is
      when S_FETCH_0 => next_state <= S_DECODE_0;
      when S_DECODE_0 => -- decode logic
        case inst(7 downto 4) is
          when "0000" => next_state <= S_MOV_0;
          when "0001" => next_state <= S_ADD_0;
          when others => next_state <= S_FETCH_0;
        end case;
      when S_MOV_0 => next_state <= S_MOV_1;
      when S_MOV_1 => next_state <= S_INC_PC_0;
      when S_ADD_0 => next_state <= S_ADD_1;
      when S_ADD_1 => next_state <= S_ADD_2;
      when S_ADD_2 => next_state <= S_INC_PC_0;
      when S_INC_PC_0 => next_state <= S_FETCH_0;
      when others => next_state <= S_FETCH_0;
    end case;
  end process;

  p_output: process (current_state, inst, opts)
  begin
    reg_oe_sel <= 0;
    reg_we <= '0';
    reg_we_sel <= 0;
    data_bus_selector_sel <= 0;
    add_sub <= 0;
    alu_selector_sel <= (others => '0');
    ir_load <= '0';
    opts_load <= '0';
    addr_bus_sel <= '0';
    pc_inc <= '0';
    ram_load <= '0';

    case current_state is
      when S_FETCH_0 =>
        -- IR = mem(PC)
        addr_bus_sel <= 0; -- addr_bus = pc;
        data_bus_selector_sel <= 2; -- data_bus <= mem(addr_bus);
        ir_load <= '1'; -- IR <= data_bus
        opts_load <= '1'; -- opts <= reg1
      when S_DECODE_0 => -- only in next_state logic
      when S_MOV_0 =>
        -- IR = mem(pc+1)
        pc_inc <= '1';
      when S_MOV_1 =>
    end case;
  end process;
end architecture;
