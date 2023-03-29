--! Project : Carry Look-Ahead Adder    
--! <br>               
--! Author : Emiliano Sisinni                   
--! <br>               
--! Date : AY2022/2023                          
--! <br>               
--! Company : UniBS                             
--! <br>               
--! File : design.vhd  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Carry_Look_Ahead is
Port ( 	A : in STD_LOGIC_VECTOR (3 downto 0);
        B : in STD_LOGIC_VECTOR (3 downto 0);
        Cin : in STD_LOGIC;
        S : out STD_LOGIC_VECTOR (3 downto 0);
        Cout : out STD_LOGIC);
end Carry_Look_Ahead;

architecture Behavioral of Carry_Look_Ahead is

component Partial_Full_Adder
Port ( 	A : in STD_LOGIC;
        B : in STD_LOGIC;
        Cin : in STD_LOGIC;
        S : out STD_LOGIC;
        P : out STD_LOGIC;
        G : out STD_LOGIC);
end component;

component CLA_logic
Port ( 	G : in STD_LOGIC_VECTOR (3 downto 0);
        P : in STD_LOGIC_VECTOR (3 downto 0);
        Cin : in STD_LOGIC;
        C : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal C,P,G: STD_LOGIC_VECTOR(3 downto 0);

begin

  PFA1: Partial_Full_Adder port map( A(0), B(0), Cin, S(0), P(0), G(0));
  PFA2: Partial_Full_Adder port map( A(1), B(1), c(0), S(1), P(1), G(1));
  PFA3: Partial_Full_Adder port map( A(2), B(2), c(1), S(2), P(2), G(2));
  PFA4: Partial_Full_Adder port map( A(3), B(3), c(2), S(3), P(3), G(3));

  logic: CLA_logic port map( G, P, Cin, C);
  
  Cout <= C(3);

end Behavioral;
