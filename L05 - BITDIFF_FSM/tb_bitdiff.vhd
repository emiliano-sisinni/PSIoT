-------------------------------------------------
-- Project : BIT DIFF               		   --
-- Author : Emiliano Sisinni                   --
-- Date : AY2022/2023                          --
-- Company : UniBS                             --
-- File : tb_bitdiff.vhd         		       --
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture BHV of tb is

  constant TEST_WIDTH : positive := 4;
  constant TIMEOUT    : time     := TEST_WIDTH*100 ns;

  signal clk          : std_logic := '0';
  signal rst          : std_logic;
  signal go           : std_logic;
  signal input        : std_logic_vector(TEST_WIDTH-1 downto 0);
  signal output_fsm1 : std_logic_vector(TEST_WIDTH-1 downto 0);
  signal output_fsm2 : std_logic_vector(TEST_WIDTH-1 downto 0);
  signal done_fsm1   : std_logic;
  signal done_fsm2   : std_logic;
  signal done         : std_logic := '0';

  function checkOutput (
    signal input : std_logic_vector)
    return signed is

    variable count : integer range -TEST_WIDTH to TEST_WIDTH;
  begin

    count := 0;

    for i in 0 to TEST_WIDTH-1 loop
      if (input(i) = '1') then
        count := count + 1;
      else
        count := count - 1;
      end if;
    end loop;  -- i

    return to_signed(count, TEST_WIDTH);
  end checkOutput;

begin

  U_FSM_1PROC : entity work.bit_diff(FSM_1P)
    generic map (
      width  => TEST_WIDTH)
    port map (
      clk    => clk,
      rst    => rst,
      go     => go,
      input  => input,
      output => output_fsm1,
      done   => done_fsm1);

  U_FSM_2PROC : entity work.bit_diff(FSM_2P)
    generic map (
      width  => TEST_WIDTH)
    port map (
      clk    => clk,
      rst    => rst,
      go     => go,
      input  => input,
      output => output_fsm2,
      done   => done_fsm2);


  clk <= not clk after 10 ns when done = '0' else
         clk;

  process
  begin
    rst   <= '1';
    go    <= '0';
    input <= (others => '0');
    for i in 0 to 5 loop
      wait until clk'event and clk = '1';
    end loop;  -- i

    rst <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';

    -- exhaustive test: this will take a long time for large widths

    for i in 0 to 2**TEST_WIDTH-1 loop
      input <= std_logic_vector(to_unsigned(i, TEST_WIDTH));
      go    <= '1';
      wait until clk'event and clk = '1';
      go    <= '0';
      wait for TIMEOUT;
    end loop;  -- i

    report "SIMULATION COMPLETE!!!!";
    done <= '1';
    wait;

  end process;

  process
  begin
    wait until go = '1';
    wait until done_fsm1 = '1' for TIMEOUT;
    assert(done_fsm1 = '1') report "fsm_1P never asserts done.";
    assert(signed(output_fsm1) = checkOutput(input)) report "Output from fsm_1P is incorrect";
  end process;

  process
  begin
    wait until go = '1';
    wait until done_fsm2 = '1' for TIMEOUT;
    assert(done_fsm2 = '1') report "fsm_2P never asserts done.";
    assert(signed(output_fsm2) = checkOutput(input)) report "Output from fsm_2P is incorrect";
  end process;

end BHV;
