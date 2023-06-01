--! Project : Edge Detector (Moore and Mealy)    
--! <br>               
--! Author : Emiliano Sisinni                   
--! <br>               
--! Date : AY2022/2023                          
--! <br>               
--! Company : UniBS                             
--! <br>               
--! File : edgedetector_testbench.vhd 

library ieee;
use ieee.std_logic_1164.all;

entity edge_detector_testbench is
end edge_detector_testbench;

architecture tb_arch of edge_detector_testbench is
signal reset,clk: std_logic;
signal input: std_logic;
signal output_Moore, output_Mealy: std_logic ;

begin
dut1: entity work.edgeDetector(arch) port map (clk => clk, reset=>reset, level => input, Moore_tick => output_Moore, Mealy_tick => output_Mealy);

-- Clock process definitions
clock_process :process
begin
     clk <= '0';
     wait for 10 ns;
     clk <= '1';
     wait for 10 ns;
end process;


-- Stimulus process
stim_proc: process
begin        
   input <= '0';
   -- hold reset state for 20 ns.
     reset <= '1';
   wait for 20 ns;    
    reset <= '0';
   wait for 5 ns;    
    input <= '1';
   wait for 130 ns;    
   input <= '0';
   wait for 25 ns;    
    input <= '1';
   wait for 105 ns;    
    input <= '0';
   wait;
end process;
end tb_arch;
