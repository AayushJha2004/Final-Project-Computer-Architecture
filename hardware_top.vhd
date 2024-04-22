library ieee; -- Importing IEEE standard library
use ieee.std_logic_1164.all; -- Using standard logic data types
use ieee.numeric_std.all; -- Using numeric data types

entity hardware_top is -- Entity declaration
    port(
        clk, reset: in std_logic; -- Clock and reset inputs
        input_1, input_2: in std_logic_vector (63 downto 0); -- Two 64-bit input vectors
        start: in std_logic; -- Start signal for operation initiation
        operation: in std_logic; -- Operation selector: '0' for multiplication, '1' for division
        ready: out std_logic; -- Output indicating readiness
        rep_check: out std_logic_vector (7 downto 0); -- Output for repetition check
        result: out std_logic_vector (128 downto 0) -- Output for result of operation
    );
end hardware_top;

architecture arch of hardware_top is -- Architecture declaration
    -- signal declarations
    signal data_1: std_logic_vector (63 downto 0); -- Signal to hold input_1
    signal sum: std_logic_vector (64 downto 0); -- Signal for sum result
    signal ld, wr, l_shift, r_shift, diff_check: std_logic; -- Control signals
    signal rep_check_out: std_logic_vector (7 downto 0); -- Output of repetition check
    signal data_2: std_logic_vector (128 downto 0); -- Signal to hold input_2 and result
    signal op_flag: std_logic; -- Flag for operation type (multiplication or division)

begin
    -- component instantiations

    register_64_bit_unit: entity work.register_64_bit -- Instance of 64-bit register
        port map(clk => clk, reset => reset, input_1 => input_1, data_1 => data_1);

    ALU_64_bit_unit: entity work.ALU_64_bit -- Instance of 64-bit Arithmetic Logic Unit (ALU)
        port map(num_1 => data_1, num_2 => data_2(128 downto 64), sum => sum, diff_check => diff_check, op_flag => op_flag);
    
    control_test_unit: entity work.control_test -- Instance of control test unit
        port map(clk => clk, reset => reset, start => start, lsb_register_129 => data_2(0), operation => operation, diff_check => diff_check, ready => ready, ld => ld, wr => wr, l_shift => l_shift, r_shift => r_shift, rep_check => rep_check_out, op_flag => op_flag);

    register_129_bit_unit: entity work.register_129_bit -- Instance of 129-bit register
        port map(clk => clk, reset => reset, input_2 => input_2, sum => sum, ld => ld, wr => wr, l_shift => l_shift, r_shift => r_shift, op_flag => op_flag, data_2 => data_2);
        
    -- outputs
    rep_check <= rep_check_out; -- Assigning repetition check output
    result <= data_2; -- Assigning result output
end arch;
