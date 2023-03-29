--! Project : Priority Encoder                  
--! <br>               
--! Author : Emiliano Sisinni                   
--! <br>               
--! Date : AY2022/2023                          
--! <br>               
--! Company : UniBS                             
--! <br>               
--! File : prio_encoder_tb.vhd                  

--=============================
-- Testbench
--=============================
library IEEE;
use IEEE.std_logic_1164.all;

entity prio_encoder42_tb is
end prio_encoder42_tb;

architecture prio_encoder42_tb_arch of prio_encoder42_tb is
signal r: std_logic_vector(3 downto 0);
signal code_cond, code_sel, code_if, code_case: std_logic_vector(1 downto 0);             
signal active_cond, active_sel,active_if, active_case: std_logic;             

component prio_encoder42 port (
      r: in std_logic_vector(3 downto 0);
      code: out std_logic_vector(1 downto 0);
      active: out std_logic);  
end component;

for dut1 : prio_encoder42
   use entity work.prio_encoder42(cond_arch);
for dut2 : prio_encoder42
   use entity work.prio_encoder42(sel_arch);
for dut3 : prio_encoder42
   use entity work.prio_encoder42(if_arch);
for dut4 : prio_encoder42
   use entity work.prio_encoder42(case_arch);

begin
   dut1: prio_encoder42 port map (
      r => r,
      code => code_cond,
      active => active_cond);

   dut2: prio_encoder42 port map (
      r => r,
      code => code_sel,
      active => active_sel);

   dut3: prio_encoder42 port map (
      r => r,
      code => code_if,
      active => active_if);

   dut4: prio_encoder42 port map (
      r => r,
      code => code_case,
      active => active_case);
 
   stimuli: process
   variable err_cnt: integer :=0;
   begin
   
      r <= "XXXX";    
      -- case input r equal "1111"
      wait for 20 ns;
      r <= "1111";	  
      wait for 10 ns;
      assert ((code_cond = "11") and (code_sel = "11") and (code_if = "11") and (code_case = "11")) report "Error Case 1" severity error;
      if ( (code_cond /= "11") and (code_sel /= "11") and (code_if /= "11") and (code_case /= "11") ) then 
         err_cnt := err_cnt+1;
      end if;

      -- case input r equal "0111"
      wait for 20 ns;
      r <= "0111";	  
      wait for 10 ns;
      assert ((code_cond = "10") and (code_sel = "10") and (code_if = "10") and (code_case = "10")) report "Error Case 2" severity error;
      if ( (code_cond /= "10") and (code_sel /= "10") and (code_if /= "10") and (code_case /= "10") ) then 
         err_cnt := err_cnt+1;
      end if;

      -- case input r equal "0011"
      wait for 20 ns;
      r <= "0011";	  
      wait for 10 ns;
      assert ((code_cond = "01") and (code_sel = "01") and (code_if = "01") and (code_case = "01")) report "Error Case 3" severity error;
      if ( (code_cond /= "01") and (code_sel /= "01") and (code_if /= "01") and (code_case /= "01") ) then 
         err_cnt := err_cnt+1;
      end if;

      -- case input r equal "0001"
      wait for 20 ns;
      r <= "0001";	  
      wait for 10 ns;
      assert ((code_cond = "00") and (code_sel = "00") and (code_if = "00") and (code_case = "00")) report "Error Case 4" severity error;
      if ( (code_cond /= "00") and (code_sel /= "00") and (code_if /= "00") and (code_case /= "00") ) then 
         err_cnt := err_cnt+1;
      end if;

     wait;
  end process stimuli;
end prio_encoder42_tb_arch; 
