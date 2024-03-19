library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity WB_stage is
  port (
    reg_write_sel      : in  natural range 0 to 7;
    we                 : in  std_logic;
    input              : in  std_logic_vector(15 downto 0);
    reg_file_write_sel : out natural range 0 to 7;
    reg_file_we        : out std_logic;
    reg_file_input     : out std_logic_vector(15 downto 0));
end entity;

architecture WB_stage_arch of WB_stage is
begin
  reg_file_write_sel <= reg_write_sel;
  reg_file_we        <= we;
  reg_file_input     <= input;
end architecture;
