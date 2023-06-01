-------------------------------------------------
-- Project : SPI FIR       		               --
-- Author : Emiliano Sisinni                   --
-- Date : AY2022/2023                          --
-- Company : UniBS                             --
-- File : fir.vhd             		           --
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
use work.coeffs_package.all;

-- /* Filter order = number of unit delays. */
entity fir is 
	generic(
		order: positive:=30; 
		data_w: positive:=16;
		guardbits: integer := 1
	);
	port(
		reset:in std_logic;			
        -- asserting reset will start protocol sequence transmission. 
        -- To restart the re-transmission of the sequence, re-assert this reset signal, and the whole SPI sequence will be re-transmitted again.
		clk: in std_logic;
		enable: in std_logic;
		-- Filter ports.
		u:in std_logic_vector(data_w-1 downto 0):=(others=>'0');
		y:buffer std_logic_vector(data_w-1 downto 0)
	);
end entity fir;

architecture rtl of fir is
	-- Explicitly define all multiplications with the "*" operator to use dedicated DSP hardware multipliers. 
	attribute multstyle:string; attribute multstyle of rtl:architecture is "dsp";	--altera
   --	attribute mult_style:string; attribute mult_style of fir:entity is "block";		--xilinx

	signal q:signed(data_w-1 downto 0):=(others=>'0');
	type signed_vector is array(natural range <>) of signed(data_w-1 downto 0);		
   type signedx2_vector is array(natural range<>) of signed(2*data_w+guardbits-1 downto 0);

	-- Pipes and delay chains.
	signal y0:signed(2*data_w+guardbits-1 downto 0);
	signal u_pipe:signed_vector(b'range):=(others=>(others=>'0'));
	signal y_pipe:signedx2_vector(b'range):=(others=>(others=>'0'));
	
begin
	newinput: process(clk) is begin
		if rising_edge(clk) then 
			if enable = '1' then
				u_pipe(0)<=signed(u);
			end if;
		end if;
	end process newinput;
	-- u_pipe(0)<=signed(u);
	y_pipe(0)<=resize(b(0)* u_pipe(0), 2*data_w+guardbits);
	-- coeffs b are defined in the coeffs_package

	u_dlyChain: for i in 1 to u_pipe'high generate
		delayChain: process(clk) is begin
			if rising_edge(clk) then 
				if enable = '1' then
					u_pipe(i)<=u_pipe(i-1); 
				end if;
			end if;
		end process delayChain;
	end generate u_dlyChain;
	
    y_dlyChain: for i in 1 to y_pipe'high generate
		y_pipe(i)<=resize(b(i)*u_pipe(i), 2*data_w+guardbits) + y_pipe(i-1);
	end generate y_dlyChain;
	
	y0<=y_pipe(y_pipe'high) when reset='0' else (others=>'0');
	y<=std_logic_vector(y0(2*data_w+guardbits-1-1 downto data_w+guardbits-1)); -- we have 2 sign bits

-- y <= u;
end architecture rtl;
