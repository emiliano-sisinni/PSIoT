-------------------------------------------------
-- Project : BIT DIFF               		   --
-- Author : Emiliano Sisinni                   --
-- Date : AY2022/2023                          --
-- Company : UniBS                             --
-- File : bit_diff.vhd   		               --
-------------------------------------------------


-- Description: This entity implements a bit difference calculator. Given an
-- input of a generic width, the entity calculates the difference between the
-- number of 1s and 0s. If there are 3 more 1s than 0s, the output is 3. If
-- there are 3 more 0s than 1s, the output is -3.
--
-- Note: There are dozens of ways of implementing the bit difference
-- calculator. The following examples are not necessarily the most efficient,
-- and are simply used to introduce the FSM. 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bit_diff is
  generic (
    width  :     positive := 16);
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    go     : in  std_logic;
    input  : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width-1 downto 0);
    done   : out std_logic);
end bit_diff;

-- The 1-process FSM model is a convenient way to combine the controller and
-- datapath for an algorithm. However, because all assigned signals are
-- implemented as registers, this model has the same weakness as the 1-process
-- FSM model. Use this model when timing is not important, and when you don't
-- care about the exact structure that is created.
--
-- The 1-process FSMD is essentially a 1-process FSM with datapath-like
-- operations integrated into each state.
--
-- As always, I recommend drawing the FSM first, and then
-- within each state, include the appropriate operations that will occur.

architecture FSM_1P of bit_diff is

  type STATE_TYPE is (S_INIT, S_CHECK_BIT, S_DONE);
  signal state : STATE_TYPE;

  signal value : std_logic_vector(width-1 downto 0);
  signal diff  : signed(width-1 downto 0);

  -- integers are ok to use, but make sure you constrain their range, otherwise
  -- they will be 32 bits, which is often a waste of area
  signal     count : integer range 0 to width;
begin
  process(clk, rst)
    variable temp  : integer range 0 to width;
  begin
    if (rst = '1') then
      -- initialize all outputs, internal signals, and the state
      output <= (others => '0');
      done   <= '0';
      value  <= (others => '0');
      count  <= 0;
      diff   <= (others => '0');
      state  <= S_INIT;
    elsif (clk'event and clk = '1') then

      -- The FSM defines output logic and next state logic for
      -- each state. However, the FSMD also includes arithmetic operations for
      -- each state that would normally be associated with a datapath.
      
      -- Note that all the following states are directly translated from the 
      -- illustration in the fsmd.pdf file.

      case state is
        -- initialize various signals, and wait for go to be asserted
        when S_INIT =>

          -- output logic and arithmetic operations (none for this state)   
          done  <= '0';
          count <= 0;
          diff  <= (others => '0');

          -- store the input into a register so that it can't change while
          -- the FSMD is computing the output. Note that by storing
          -- input into another signal, the signal is implemented as a
          -- register because this happens on the rising edge of the clock.
          value <= input;

          -- next state logic
          if (go = '1') then
            state <= S_CHECK_BIT;
          end if;

        when S_CHECK_BIT =>

          -- output logic (none for this state) and arithmetic operations
          
          -- check the lowest bit for '0' or '1' and update diff accordingly.
          if (value(0) = '0') then
            diff <= diff - 1;
          elsif (value(0) = '1') then
            diff <= diff + 1;
          end if;

          -- shift right so that on the next cycle we can check the next bit
          value <= std_logic_vector(shift_right(unsigned(value), 1));
          -- can also do
          -- value <= "0" & value(width-1 downto 1);

          temp := count + 1;
          count <= temp;

          -- next state logic
          if (temp = width) then
            state <= S_DONE;
          end if;

        when S_DONE =>
          -- output logic and arithmetic operations (none for this state)
          output <= std_logic_vector(diff);
          done   <= '1';

          -- next state logic
          state  <= S_INIT;

        when others => null;
      end case;
    end if;
  end process;
end FSM_1P;


-- The 2-process FSM is more flexible than the 1-process FSM because it does
-- not implement all assignments as registers. However, the 2-process FSM is
-- trickier at first. 

architecture FSM_2P of bit_diff is

  type STATE_TYPE is (S_INIT, S_CHECK_BIT, S_STORE_OUTPUT, S_DONE);

  -- One key difference in the 2-process FSM model is that anything
  -- implemented as a register must be declared as two signals: one for the
  -- current value and one that defines the register on the next clock cycle.
  -- I use the convention of adding a next_ prefix for the signal that defines
  -- the value on the next clock cycle. Using this convention, anything with a
  -- next_ prefix is implemented with combinational logic, and the
  -- corresponding sigals with the prefix are implemented as registers.
  signal state, next_state : STATE_TYPE;
  signal value, next_value : std_logic_vector(width-1 downto 0);
  signal diff, next_diff   : signed(width-1 downto 0);
  signal count, next_count : integer range 0 to width;

  -- Note the _s suffix on output_s. I use this convention when I need to read
  -- from a signal that is connected to an output. I can't read from "output"
  -- directly because it is an "out" signal, so instead I use an internal
  -- signal with the same name and a _s suffix. I can then read from
  -- "output_s", which is currently assigned to "output". If you are wondering
  -- why the code has to read from "output", the reason is that the
  -- combinational process must define the next value of all registers. For the
  -- output register, the next value will usually be the current value, except
  -- for the S_DONE state. Therefore, we need to be able to read the current
  -- value. 
  signal output_s, next_output : std_logic_vector(width-1 downto 0);
begin

  -- this process defines all registers used in the FSM
  process(clk, rst)
  begin
    if (rst = '1') then
      value    <= (others => '0');
      count    <= 0;
      diff     <= (others => '0');
      output_s <= (others => '0');
      state    <= S_INIT;
    elsif (clk'event and clk = '1') then
      -- these are the only registers used by the 2-process FSM
      value    <= next_value;
      count    <= next_count;
      diff     <= next_diff;
      output_s <= next_output;
      state    <= next_state;
    end if;
  end process;

  -- combinational logic, so make to to follow all corresponding synthesis
  -- coding guidelines
  process(go, input, value, count, diff, output_s, state)
    variable temp : integer range 0 to width;
  begin
    -- assign default values for all combinational outputs. Anything with
    -- the next_ prefix defines the input to a register.
    -- IMPORTANT: Default values are very useful here. If they aren't used,
    -- then each path through the case statement must always define each of
    -- these signals.
    next_count  <= count;
    next_value  <= value;
    next_diff   <= diff;
    next_output <= output_s;
    next_state  <= state;

    -- done isn't a register (although I could have made it one), so we can
    -- assign values to it directly
    done <= '0';

    case state is
      when S_INIT             =>
        -- be careful not to define count, diff, or value, which are assigned
        -- by the sequential process. All register inputs must be assigned
        -- with the signal that has a next_ prefix
        next_count <= 0;
        next_diff  <= (others => '0');
        next_value <= input;

        -- Notice that next_state is not defined for go='0'. Normally, this
        -- would cause a latch, but because I defined a default value for next_
        -- state, no latch is inferred. 
        if (go = '1') then
          next_state <= S_CHECK_BIT;
        end if;

      when S_CHECK_BIT =>

        -- Notice how I'm reading from "diff" and writing to "next_diff".
        -- "diff" is the current register output. "next_diff" is the value
        -- that will be stored in the register on the next cycle.

        if (value(0) = '0') then
          next_diff <= diff - 1;
        elsif (value(0) = '1') then
          next_diff <= diff + 1;
        end if;

        -- Again, I'm assigning "next_value" and not "value".
        next_value <= std_logic_vector(shift_right(unsigned(value), 1));
        temp := count + 1;
        next_count <= temp;

        if (temp = width) then
          next_state <= S_STORE_OUTPUT;
        end if;

        -- In the 2-process model, I had to add an extra state to store the
        -- output. If I had stored the output in the same state that I asserted
        -- done, done would be asserted one cycle before the actual output
        -- appeared, because done is not implemented as a register. If I had
        -- implemented done as a register, I could have eliminated this state.

      when S_STORE_OUTPUT =>
        next_output <= std_logic_vector(diff);
        next_state  <= S_DONE;

      when S_DONE =>
        done       <= '1';
        next_state <= S_INIT;

      when others => null;
    end case;
  end process;

  -- concurrent assignment of internal output_s signal to the corresponding
  -- output. 
  output <= output_s;

end FSM_2P;

