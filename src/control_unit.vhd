library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_unsigned.all;

entity control_unit is
  port (
    inst                  : in  std_logic_vector(10 downto 0);
    counter               : in  std_logic_vector(1 downto 0);
    -- registers
    no_reg                : out std_logic; -- means no register is getting input
    reg_decoder_sel       : out std_logic_vector(2 downto 0);
    reg_selector_sel      : out std_logic_vector(2 downto 0);
    data_bus_selector_sel : out std_logic_vector(1 downto 0);
    -- alu
    add_sub               : out std_logic;
    alu_selector_sel      : out std_logic_vector(2 downto 0);
    -- memory
    ram_load              : out std_logic;
    -- control unit
    done                  : out std_logic);
end entity;

architecture control_unit_arch of control_unit is
begin
  process (inst, counter)
  begin
    case inst(10 downto 7) is
      when "0000" =>
        -- data_bus_sel <= reg_b, reg_decoder <= None
        -- reg_decoder <= reg_a
        if counter = "00" then
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(2 downto 0);
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '0';
        elsif counter = "01" then
          no_reg <= '0';
          reg_decoder_sel <= inst(5 downto 3);
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(2 downto 0);
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '1';
        else
          no_reg <= '0';
          reg_decoder_sel <= inst(5 downto 3);
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(2 downto 0);
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '1';
        end if;
      when "0001" =>
        if counter = "00" then
          -- data_bus <= reg_b
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(5 downto 3); -- VV
          data_bus_selector_sel <= "00"; -- data_bus <= reg_a
          ram_load <= '0';
          done <= '0';
        elsif counter = "01" then
          -- alu_in <= reg_a
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= inst(2 downto 0); -- alu_in <= reg_b
          reg_selector_sel <= inst(5 downto 3); -- VV
          data_bus_selector_sel <= "00"; -- data_bus <= reg_a
          ram_load <= '0';
          done <= '0';
          -- alu_out <= reg_a + reg_b
          -- acc <= alu_out
        elsif counter = "10" then
          -- data_bus <= acc
          no_reg <= '0';
          reg_decoder_sel <= inst(5 downto 3); -- reg_a <= data_bus
          add_sub <= '0';
          alu_selector_sel <= inst(2 downto 0); -- alu_in <= reg_b
          reg_selector_sel <= inst(5 downto 3);
          data_bus_selector_sel <= "01";
          ram_load <= '0';
          done <= '1';
        else
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= "000";
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '1';
        end if;
      when "0010" =>
        if counter = "00" then
          -- data_bus <= reg_b
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '1';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(2 downto 0);
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '0';
        elsif counter = "01" then
          -- alu_in <= reg_a
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '1';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(5 downto 3);
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '0';
        else
          -- data_bus <= acc
          no_reg <= '0';
          reg_decoder_sel <= inst(5 downto 3); -- reg_a
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(5 downto 3); -- reg_a
          data_bus_selector_sel <= "01";
          ram_load <= '0';
          done <= '1';
        end if;
      when "0110" => -- LD
        if counter = "00" then
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= "000";
          data_bus_selector_sel <= "10"; -- mem
          ram_load <= '0';
          done <= '0';
        elsif counter = "01" then
          no_reg <= '0';
          reg_decoder_sel <= inst(5 downto 3); -- reg_a
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= "000";
          data_bus_selector_sel <= "10";
          ram_load <= '0';
          done <= '1';
        else
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= "000";
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '1';
        end if;
      when "1000" => -- STO
        if counter = "00" then
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(5 downto 3); -- reg_a
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '0';
        elsif counter = "01" then
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= inst(5 downto 3); -- reg_a
          data_bus_selector_sel <= "00";
          ram_load <= '1';
          done <= '1';
        else
          no_reg <= '1';
          reg_decoder_sel <= "000";
          add_sub <= '0';
          alu_selector_sel <= "000";
          reg_selector_sel <= "000";
          data_bus_selector_sel <= "00";
          ram_load <= '0';
          done <= '1';
        end if;
      when others =>
        no_reg <= '1';
        reg_decoder_sel <= "000";
        add_sub <= '1';
        alu_selector_sel <= "000";
        reg_selector_sel <= "000";
        data_bus_selector_sel <= "00";
        ram_load <= '0';
        done <= '1';
    end case;
  end process;
end architecture;
