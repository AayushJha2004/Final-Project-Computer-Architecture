library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_64_bit is
    port(
        num_1: in std_logic_vector (63 downto 0); -- Input 1 (64 bits)
        num_2: in std_logic_vector (64 downto 0); -- Input 2 (65 bits)
        op_flag: in std_logic; -- Operation flag ('0' for addition, '1' for subtraction)
        diff_check: out std_logic; -- Output indicating if subtraction result is negative
        sum: out std_logic_vector (64 downto 0) -- Output sum (65 bits)
    );
end ALU_64_bit;

architecture arch of ALU_64_bit is 
    signal num_1_unsg: unsigned (64 downto 0); -- Signal for storing unsigned version of input 1
    signal num_2_unsg: unsigned (64 downto 0); -- Signal for storing unsigned version of input 2
    signal diff_unsg: unsigned (64 downto 0); -- Signal for storing unsigned difference
    signal sum_unsg: unsigned (64 downto 0); -- Signal for storing unsigned sum
begin
    num_1_unsg <= '0' & unsigned(num_1); -- Convert input 1 to unsigned and pad with 0
    num_2_unsg <= unsigned(num_2); -- Convert input 2 to unsigned
    diff_unsg <= num_2_unsg - num_1_unsg; -- Calculate unsigned difference
    sum_unsg <= num_2_unsg + num_1_unsg; -- Calculate unsigned sum
    diff_check <= '1' when (num_2_unsg < num_1_unsg) else '0'; -- Set diff_check to '1' if subtraction result is negative
    sum <= std_logic_vector(sum_unsg) when op_flag = '0' else std_logic_vector(diff_unsg); -- Output sum or difference based on operation flag
end arch;
