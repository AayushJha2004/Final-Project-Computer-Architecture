library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_test is
    port(
        clk, reset: in std_logic; -- Clock and reset inputs
        start: in std_logic; -- Start signal for operation initiation
        operation: in std_logic; -- Operation selector ('0' for multiplication, '1' for division)
        lsb_register_129: in std_logic; -- Least Significant Bit of Register 129
        diff_check: in std_logic; -- Difference check for division operation
        ready: out std_logic; -- Output indicating readiness
        ld: out std_logic; -- Load signal for register control
        wr: out std_logic; -- Write signal for register control
        l_shift: out std_logic; -- Left shift signal for division operation
        r_shift: out std_logic; -- Right shift signal for multiplication operation
        op_flag: out std_logic; -- Operation flag output
        rep_check: out std_logic_vector (7 downto 0) -- Repetition check output
    );
end control_test;

architecture arch of control_test is
    -- Signal declarations
    signal ready_mul, ready_div: std_logic; -- Ready signals for multiplication and division units
    signal ld_mul, ld_div: std_logic; -- Load signals for multiplication and division units
    signal wr_mul, wr_div: std_logic; -- Write signals for multiplication and division units
    signal r_shift_mul, r_shift_div: std_logic; -- Right shift signals for multiplication and division units
    signal l_shift_div: std_logic; -- Left shift signal for division unit
    signal rep_check_mul, rep_check_div: std_logic_vector (7 downto 0); -- Repetition check signals for multiplication and division units
begin
    -- Instantiating control units for multiplication and division
    control_test_multiplier_unit: entity work.control_test_multiplier
        port map(clk => clk, reset => reset, start => start, lsb_register_129 => lsb_register_129, ready => ready_mul, ld => ld_mul, wr => wr_mul, r_shift => r_shift_mul, rep_check => rep_check_mul);
       
    control_test_divider_unit: entity work.control_test_divider
        port map(clk => clk, reset => reset, start => start, diff_check => diff_check, ready => ready_div, ld => ld_div, wr => wr_div, l_shift => l_shift_div, r_shift => r_shift_div, rep_check => rep_check_div);

    -- Process for selecting signals based on operation
    process(operation, ready_mul, ready_div, ld_mul, ld_div, wr_mul, wr_div, r_shift_mul, r_shift_div, l_shift_div, rep_check_mul, rep_check_div)
    begin
        ready <= '0'; -- Initialize ready signal
        ld <= '0'; -- Initialize load signal
        wr <= '0'; -- Initialize write signal
        l_shift <= '0'; -- Initialize left shift signal
        r_shift <= '0'; -- Initialize right shift signal
        rep_check <= (others => '0'); -- Initialize repetition check signal
        case operation is
            when '0' => -- Multiplication operation
                ready <= ready_mul; -- Set ready signal based on multiplication unit
                ld <= ld_mul; -- Set load signal based on multiplication unit
                wr <= wr_mul; -- Set write signal based on multiplication unit
                l_shift <= '0'; -- No left shift for multiplication
                r_shift <= r_shift_mul; -- Set right shift signal based on multiplication unit
                rep_check <= rep_check_mul; -- Set repetition check signal based on multiplication unit
            when others => -- Division operation
                ready <= ready_div; -- Set ready signal based on division unit
                ld <= ld_div; -- Set load signal based on division unit
                wr <= wr_div; -- Set write signal based on division unit
                l_shift <= l_shift_div; -- Set left shift signal based on division unit
                r_shift <= r_shift_div; -- Set right shift signal based on division unit
                rep_check <= rep_check_div; -- Set repetition check signal based on division unit
        end case;
    end process;
    op_flag <= operation; -- Output the operation flag
end arch;
