-------------------------------------------------
-- Project : SPI FIR       		              --
-- Author : Emiliano Sisinni                   --
-- Date : AY2022/2023                          --
-- Company : UniBS                             --
-- File : basic_spi.vhd   	      	           --
-------------------------------------------------

----------------------------------------------------------------------------------
-- Basic SPI implementation. Use MODE1.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;

entity basic_spi is
generic(
			ADDR_W 	: integer	:= 3;				-- data width in bits
			DATA_W 	: integer	:= 8;				-- data width in bits
			Nbit 	: integer	:= 3 					-- log2(data width)
			);
port( OSC_FPGA : in std_logic;
		PB : in std_logic_vector(1 downto 0);
		SYS_SPI_MOSI : in std_logic;
		SYS_SPI_SCK : in std_logic;
		SYS_SPI_MISO: out std_logic;
		LED : out std_logic_vector(1 downto 0) := (others => '0')
);
end basic_spi;

architecture Behavioral of basic_spi is
	
	signal pb0_synchronizer: std_logic_vector(2 downto 0);
	signal reset:std_logic;
	signal newdata:std_logic;
	signal data_in:std_logic_vector(DATA_W-1 downto 0);
	signal data_out:std_logic_vector(DATA_W-1 downto 0);
	
begin
	
	blink_hb : entity work.blink_heartbeat port map(CLK => OSC_FPGA, LED => LED(0));

	spi_fir: entity work.fir
	generic map (
		-- order => 3, 
		order => 10, 
		data_w => data_w,
		guardbits => 3 -- log2(taps)-1 = log2(order+1)-1
	)
	port map(
		reset => reset,			
		clk => OSC_FPGA,
		enable => newdata,
		u => data_out,
		y => open --y => data_in use open for loopback
	);

	spi: entity work.spi
		GENERIC MAP (
			DATA_W 	=> DATA_W, 			-- data width in bits
			Nbit 	=> Nbit 			-- log2(data width)
		)
		PORT MAP (
		clk => OSC_FPGA,
        reset => reset,
		  data_in => data_out, --data_in => data_in,  use data_out for loopback
        data_out => data_out,
        rd => open,
        wr => newdata,
        SCK => SYS_SPI_SCK,
        MOSI => SYS_SPI_MOSI,
        MISO => SYS_SPI_MISO
	);
	
	process(OSC_FPGA, PB)
	begin
		if (rising_edge(OSC_FPGA)) then
		
			-- Synch the pushbutton and generate a reset signal
			pb0_synchronizer(2 downto 1) <= pb0_synchronizer(1 downto 0);
			pb0_synchronizer(0) <= PB(0);
		
			if pb0_synchronizer(2 downto 1) = "01" then
				-- Rising edge is button release
				LED(1) <= '0';
				reset <= '1';
			elsif (reset = '1') then
				LED(1) <= '1';
				reset <= '0';
			end if;
		end if;
	end process ;

end Behavioral;

