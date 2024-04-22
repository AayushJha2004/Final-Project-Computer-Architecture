library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_64_bit is
    port(
        clk, reset: in std_logic; -- Clock and reset inputs
        input_1: in std_logic_vector (63 downto 0); -- Input data
        data_1: out std_logic_vector (63 downto 0) -- Output data
    );
end register_64_bit;

architecture arch of register_64_bit is
    signal input_1_reg, input_1_next: std_logic_vector (63 downto 0); -- Internal signals for register storage and next state
begin
    process(clk, reset)
    begin
        if (reset = '1') then -- If reset is active
            input_1_reg <= (others => '0'); -- Reset the register to all zeros
        elsif (clk'event and clk = '1') then -- If rising edge of clock
            input_1_reg <= input_1_next; -- Update the register with the next value
        end if;
    end process;

    -- next state logic
    input_1_next <= input_1; -- Assign the input to the next state

    -- output logic
    data_1 <= input_1_reg; -- Output the current value of the register
end arch;
