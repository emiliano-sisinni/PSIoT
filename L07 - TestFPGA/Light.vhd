-------------------------------------------------
-- Project : QuartusII example       		   --
-- Author : Emiliano Sisinni                   --
-- Date : AY2021/2022                          --
-- Company : UniBS                             --
-- File : light.vhd   		                   --
-------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity light is
	port(
		SW: in std_logic_vector(3 downto 0);
		LED: out std_logic_vector(7 downto 0));
end light;

architecture logicfunction of light is
signal x1,x2,f: std_logic;
begin

	f <= (x1 and not x2) or (not x1 and x2);
	-- f <= x1 xor x2;
	x1 <= SW(0);
	x2 <= SW(1);
	LED(0) <= f;
	
end logicfunction;