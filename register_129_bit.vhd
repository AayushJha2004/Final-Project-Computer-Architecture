library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_129_bit is
    port(
        clk, reset: in std_logic; -- Clock and reset inputs
        input_2: in std_logic_vector (63 downto 0); -- Input data
        sum: in std_logic_vector (64 downto 0); -- Sum data
        ld: in std_logic; -- Load control signal
        wr: in std_logic; -- Write control signal
        l_shift: in std_logic; -- Left shift control signal
        r_shift: in std_logic; -- Right shift control signal
        op_flag: in std_logic; -- Operation flag
        data_2: out std_logic_vector (128 downto 0) -- Output data
    );
end register_129_bit;

architecture arch of register_129_bit is 
    signal data_2_reg, data_2_next: std_logic_vector (128 downto 0); -- Registers for current and next state
    signal intermediate: std_logic_vector (128 downto 0); -- Intermediate signal for shifting
begin
    process(clk , reset)
    begin
        if (reset = '1') then 
            data_2_reg <= (others => '0'); -- Reset data register on reset
        elsif (clk'event and clk = '1') then 
            data_2_reg <= data_2_next; -- Update data register with next state
        end if;
    end process;

    process(ld, input_2, wr, sum, data_2_reg, l_shift, r_shift, intermediate)
    begin
        data_2_next <= (others => '0'); -- Initialize next state to zeros
        intermediate <= (others => '0'); -- Initialize intermediate signal to zeros
        if (ld = '1') then
            data_2_next <= "00000000000000000000000000000000000000000000000000000000000000000" & input_2; -- Load input data into right half (LSB) of data register
        else
            if (op_flag = '0') then -- If operation is multiplication
                if (wr = '1') then -- if write is enables then 
                    data_2_next <= '0' & sum & data_2_reg(63 downto 1); -- Write sum data into left half of data register and right shift by 1
                elsif (r_shift = '1') then -- if write is not enabled and right shift is enabled then 
                    data_2_next <= '0' & data_2_reg (128 downto 1); -- Right shift data by 1
                end if;
            else -- if operation is division
                if (wr = '1') then -- if write is asserted then 
                    intermediate <= sum(63 downto 0) & data_2_reg(63 downto 0) & '1'; -- load alu result into left half of data register and left shift with shifted bit set to '1'
                elsif (l_shift = '1') then -- is write is not asserted and l_shift is asserted then 
                    intermediate <= data_2_reg (127 downto 0) & '0'; -- Left shift data register and store in intermediate signal
                end if;
                if (r_shift = '1') then -- if right shift is asserted (in last iteration)
                    data_2_next <= "0" & intermediate(128 downto 65) & intermediate (63 downto 0); -- Right shift left half of intermediate data and update next state of data register
                else -- if right shift is not enabled then 
                    data_2_next <= intermediate; -- Update next state with intermediate data
                end if;
            end if;
        end if;
    end process;

    data_2 <= data_2_reg; -- Output current data state
end arch;
