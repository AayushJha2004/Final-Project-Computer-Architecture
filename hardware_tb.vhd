library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hardware_tb is -- Testbench entity declaration
end entity hardware_tb;

architecture tb_arch of hardware_tb is -- Testbench architecture
    -- Constants
    constant CLK_PERIOD : time := 10 ps; -- Clock period

    -- Signals
    signal clk, reset, start, ready : std_logic; -- Control signals
    signal input_1, input_2 : std_logic_vector(63 downto 0); -- Input data signals
    signal operation: std_logic; -- Operation signal
    signal result : std_logic_vector(128 downto 0); -- Result signal
    signal rep_check: std_logic_vector(7 downto 0); -- Repetition check signal

begin
    -- Instantiate the hardware_top module
    dut : entity work.hardware_top -- Device Under Test (DUT)
        port map(
            clk          => clk,
            reset        => reset,
            input_1      => input_1,
            input_2      => input_2,
            start        => start,
            operation    => operation,
            ready        => ready,
            rep_check    => rep_check,
            result     => result
        );

    -- Clock process
    clk_process: process -- Process for generating clock signal
    begin
        while now < 2000 ns loop -- Simulation duration
            clk <= '0'; -- Clock low
            wait for CLK_PERIOD / 2; -- Wait half clock period
            clk <= '1'; -- Clock high
            wait for CLK_PERIOD / 2; -- Wait half clock period
        end loop;
        wait; -- Wait indefinitely
    end process;

    -- Stimulus process
    stimulus_process: process -- Process for generating stimulus
    begin
        -- Reset
        reset <= '1'; -- Set reset high
        start <= '0'; -- Set start low
        operation <= '0'; -- Set operation to multiplication
        input_1 <= X"0000000000000000"; -- Set input_1 to zero
        input_2 <= X"0000000000000000"; -- Set input_2 to zero
        wait for CLK_PERIOD; -- Wait one clock cycle
        reset <= '0'; -- Release reset

        -- Load 
        input_1 <= X"000000000000EEEE"; -- Load input_1 with a value
        input_2 <= X"000000000000FFFF"; -- Load input_2 with a value
        operation <= '0'; -- Set operation to multiplication
        wait for CLK_PERIOD; -- Wait one clock cycle
        -- Start operation
        start <= '1'; -- Set start high
        wait for CLK_PERIOD; -- Wait one clock cycle
        start <= '0'; -- Set start low
        -- Wait for operation to complete
        wait until ready = '1'; -- Wait until ready signal is high

        -- Engage hardware for 100 different input combinations
        for i in 56897 to 56995 loop
            -- Load 
            input_1 <= std_logic_vector(to_unsigned((i+8990)*137, 64)); -- Load input_1 with a calculated value
            input_2 <= std_logic_vector(to_unsigned((i + 7179)*(i-568)*997651917, 64)); -- Load input_2 with a calculated value
            operation <= std_logic(to_unsigned(i mod 2, 1)(0)); -- Set operation based on iteration count
            wait for CLK_PERIOD; -- Wait one clock cycle
            -- Start operation
            start <= '1'; -- Set start high
            wait for CLK_PERIOD; -- Wait one clock cycle
            start <= '0'; -- Set start low
            -- Wait for operation to complete
            wait until ready = '1'; -- Wait until ready signal is high
        end loop;
        
        wait; -- Wait indefinitely
    end process;

end architecture tb_arch;
