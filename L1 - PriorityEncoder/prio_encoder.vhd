--! Project : Priority Encoder                  
--! <br>               
--! Author : Emiliano Sisinni                   
--! <br>               
--! Date : AY2022/2023                          
--! <br>               
--! Company : UniBS                             
--! <br>                                        
--! File : prio_encoder.vhd                     

--=============================
-- Entity
--=============================
library ieee;
use ieee.std_logic_1164.all;
entity prio_encoder42 is
   port(
      r: in std_logic_vector(3 downto 0);
      code: out std_logic_vector(1 downto 0);
      active: out std_logic
   );
end prio_encoder42;

--==========================================
-- Architectures: conditional assignment
--==========================================
architecture cond_arch of prio_encoder42 is
begin
   code <= "11" when (r(3)='1') else
           "10" when (r(2)='1') else
           "01" when (r(1)='1') else
           "00";
   active <= r(3) or r(2) or r(1) or r(0);
end cond_arch;

--==========================================
-- Architectures: selected assignment
--==========================================
architecture sel_arch of prio_encoder42 is
begin
   with r select
      code <= "11" when "1000"|"1001"|"1010"|"1011"|
                        "1100"|"1101"|"1110"|"1111",
              "10" when "0100"|"0101"|"0110"|"0111",
              "01" when "0010"|"0011",
              "00" when others;
   active <= r(3) or r(2) or r(1) or r(0);
end sel_arch;

--==========================================
-- Architectures: process if
--==========================================
architecture if_arch of prio_encoder42 is
begin
   process(r)
   begin
      if (r(3)='1') then
         code <= "11";
      elsif (r(2)='1')then
         code <= "10";
      elsif (r(1)='1')then
         code <= "01";
      else
         code <= "00";
      end if;
   end process;
   active <= r(3) or r(2) or r(1) or r(0);
end if_arch;

--==========================================
-- Architectures: process case
--==========================================
architecture case_arch of prio_encoder42 is
begin
   process(r)
   begin
      case r is
         when "1000"|"1001"|"1010"|"1011"|
              "1100"|"1101"|"1110"|"1111" =>
            code <= "11";
         when "0100"|"0101"|"0110"|"0111" =>
            code <= "10";
         when "0010"|"0011" =>
            code <= "01";
         when others =>
            code <= "00";
      end case;
   end process;
   active <= r(3) or r(2) or r(1) or r(0);
end case_arch;
