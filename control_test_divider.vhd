library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity control_test_divider is
    port(
        clk, reset: in std_logic; -- Clock and reset inputs
        start: in std_logic; -- Start signal for operation initiation
        diff_check: in std_logic; -- Difference check for division operation
        ready: out std_logic; -- Output indicating readiness
        ld: out std_logic; -- Load signal for register control
        wr: out std_logic; -- Write signal for register control
        l_shift: out std_logic; -- Left shift signal for register control
        r_shift: out std_logic; -- Right shift signal for register control
        op_flag: out std_logic; -- Operation flag output
        rep_check: out std_logic_vector (7 downto 0) -- Repetition check output
    );
end control_test_divider;

architecture arch of control_test_divider is
    type state_type is (idle, load, op); -- Enumeration type for control states
    signal state_reg, state_next: state_type; -- State register and next state signal
    signal rep_check_reg, rep_check_next: unsigned (7 downto 0); -- Repetition check register and next state signal
begin
    process(clk, reset)
    begin
        if (reset = '1') then 
            state_reg <= idle; -- Initialize state register to idle
            rep_check_reg <= (others => '0'); -- Initialize repetition check register to zeros
        elsif (clk'event and clk = '1') then
            state_reg <= state_next; -- Update state register with next state
            rep_check_reg <= rep_check_next; -- Update repetition check register with next state
        end if;
    end process;

    process(start, state_reg, rep_check_reg, diff_check)
    begin
        state_next <= state_reg; -- Default next state is current state
        rep_check_next <= rep_check_reg; -- Default next repetition check is current value
        ready <= '0'; -- Initialize ready signal
        ld <= '0'; -- Initialize load signal
        wr <= '0'; -- Initialize write signal
        l_shift <= '0'; -- Initialize left shift signal
        r_shift <= '0'; -- Initialize right shift signal
        case state_reg is 
            when idle =>  
                if (start = '1') then  
                    state_next <= load; -- Transition to load state on start signal
                end if;
                ready <= '1'; -- Set ready signal to indicate readiness
            when load => 
                ld <= '1'; -- Activate load signal
                rep_check_next <= (others => '0'); -- Reset repetition check
                state_next <= op; -- Transition to operation state
            when op =>  
                rep_check_next <= rep_check_reg + 1; -- Increment repetition check
                l_shift <= '1'; -- Activate left shift
                if (diff_check = '0') then -- If difference check indicates valid operation
                    wr <= '1'; -- Activate write signal
                end if;
                if (rep_check_reg = to_unsigned(64, 8)) then -- If repetition check reaches maximum
                    r_shift <= '1'; -- Activate right shift
                    state_next <= idle;  -- Transition back to idle state
                end if;
        end case;
    end process;

    rep_check <= std_logic_vector(rep_check_reg); -- Convert repetition check register to vector for output
end arch;
