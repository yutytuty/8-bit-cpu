library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity EX_stage is
  port (
    clk                : in  std_logic;
    op1                : in  std_logic_vector(15 downto 0);
    op2                : in  std_logic_vector(15 downto 0);
    operand_forward_in : in  std_logic_vector(15 downto 0);
    operand_forward1   : in  std_logic;
    operand_forward2   : in  std_logic;
    func               : in  natural range 0 to 15;
    wb_reg             : in  natural range 0 to 7;
    wb_we              : in  std_logic;
    o                  : out std_logic_vector(15 downto 0);
    wb_reg_o           : out natural range 0 to 7;
    wb_we_o            : out std_logic);
end entity;

architecture EX_stage_arch of EX_stage is
  signal alu_a, alu_b : std_logic_vector(15 downto 0);
  signal alu_o        : std_logic_vector(15 downto 0);
  component alu is
    port (a    : in  std_logic_vector(15 downto 0);
          b    : in  std_logic_vector(15 downto 0);
          func : in  natural range 0 to 15;
          o    : out std_logic_vector(15 downto 0));
  end component;
begin
  alu_a <= op1                when operand_forward1 = '0' else
           operand_forward_in when operand_forward1 = '1' else
           op1;
  alu_b <= op2                when operand_forward2 = '0' else
           operand_forward_in when operand_forward2 = '1' else
           op2;

  c_ALU: alu
    port map (
      a    => alu_a,
      b    => alu_b,
      func => func,
      o    => alu_o
    );

  process (clk)
  begin
    if rising_edge(clk) then
      o <= alu_o;
      wb_reg_o <= wb_reg;
      wb_we_o <= wb_we;
    end if;
  end process;
end architecture;
