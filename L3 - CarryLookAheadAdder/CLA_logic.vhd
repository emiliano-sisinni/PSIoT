--! Project : Carry Look-Ahead Adder    
--! <br>               
--! Author : Emiliano Sisinni                   
--! <br>               
--! Date : AY2022/2023                          
--! <br>               
--! Company : UniBS                             
--! <br>               
--! File : CLA_logic.vhd  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLA_logic is
Port ( 	G : in STD_LOGIC_VECTOR (3 downto 0);
        P : in STD_LOGIC_VECTOR (3 downto 0);
        Cin : in STD_LOGIC;
        C : out STD_LOGIC_VECTOR (3 downto 0));
end CLA_logic;

architecture Behavioral of CLA_logic is
begin

  c(0) <= G(0) OR (P(0) AND Cin);
  c(1) <= G(1) OR (P(1) AND G(0)) OR (P(1) AND P(0) AND Cin);
  c(2) <= G(2) OR (P(2) AND G(1)) OR (P(2) AND P(1) AND G(0)) OR (P(2) AND P(1) AND P(0) AND Cin);
  C(3) <= G(3) OR (P(3) AND G(2)) OR (P(3) AND P(2) AND G(1)) OR (P(3) AND P(2) AND P(1) AND G(0)) OR (P(3) AND P(2) AND P(1) AND P(0) AND Cin);

end architecture;