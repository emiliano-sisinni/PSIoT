-------------------------------------------------
-- Project : SPI FIR       		              --
-- Author : Emiliano Sisinni                   --
-- Date : AY2021/2022                          --
-- Company : UniBS                             --
-- File : spi.vhd             		           --
-------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


entity spi is
	Generic(
			DATA_W 	: integer	:= 8;				-- data width in bits
			Nbit 	: integer	:= 3 					-- log2(data width)
			);
    Port ( clk : in STD_LOGIC;
           reset : in  STD_LOGIC;
			  data_in : in  STD_LOGIC_VECTOR (DATA_W-1 downto 0);
           data_out : out  STD_LOGIC_VECTOR (DATA_W-1 downto 0)  := (others => '0');
           rd : out  STD_LOGIC := '0';
           wr : out  STD_LOGIC := '0';
           SCK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC := '0');
end spi;

architecture Behavioral of spi is
--	constant all_ones : std_logic_vector(Nbit-1 downto 0) := (others => '1');
--	constant all_zeros : std_logic_vector(Nbit-1 downto 0) := (others => '0');
	constant all_ones : unsigned(Nbit-1 downto 0) := (others => '1');
	constant all_zeros : unsigned(Nbit-1 downto 0) := (others => '0');
 
	signal spi_value: std_logic_vector(DATA_W-1 downto 0) := (others => '0');
	signal spi_readvalue: std_logic_vector(DATA_W-1 downto 0):= (others => '0');
	signal sck_synchronizer: std_logic_vector(2 downto 0):= (others => '0');

--	signal rdcnt: std_logic_vector(Nbit-1 downto 0) := (others => '0'); --"000";
--	signal wrcnt: std_logic_vector(Nbit-1 downto 0) := (others => '0'); --"000";
	signal rdcnt: unsigned(Nbit-1 downto 0) := (others => '0'); --"000";
	signal wrcnt: unsigned(Nbit-1 downto 0) := (others => '0'); --"000";
	signal feed_me: std_logic := '0';
	signal read_me: std_logic := '0';

begin
process(clk, reset)
	begin
		if (rising_edge(clk)) then

			-- Synch the SPI clock
			sck_synchronizer(2 downto 1) <= sck_synchronizer(1 downto 0);
			sck_synchronizer(0) <= SCK;
	
			if (reset = '1') then
				spi_value <= (others => '0'); --X"00"; 
				spi_readvalue <= (others => '0'); --X"00";
				MISO <= '0'; -- Mode1 means this value should never get sampled
				rdcnt <= (others => '0'); --"000";
				wrcnt <= (others => '0'); --"000";
				rd <= '0';
				wr <= '0';
				read_me <= '0';
				feed_me <= '0';
				data_out <= (others => '0');
			else						
				-- SPI MODE 1: clock rests low, assert on rise, latch on fall.
				if (sck_synchronizer(2 downto 1) = "01") then
					-- rise: assert
					spi_value <= spi_value(DATA_W-2 downto 0) & '0';
					MISO <= spi_value(DATA_W-1);
					wrcnt <= wrcnt+1;					
					if (wrcnt = all_ones) then
					--if ( conv_integer(wrcnt) = 2**Nbit-1 ) then
						wrcnt <= (others => '0');
						feed_me <= '1';
						rd <= '1';
					end if;
				else
					if (sck_synchronizer(2 downto 1) = "10") then
					-- fall: sample
						spi_readvalue(DATA_W-1 downto 1) <= spi_readvalue(DATA_W-2 downto 0);
						spi_readvalue(0) <= MOSI;
					   rdcnt <= rdcnt+1;
						if (rdcnt = all_ones) then
							rdcnt <= (others => '0');
							read_me <= '1';
							wr <= '1';
						end if;						
					
					end if;
				end if;			
				if (feed_me = '1') then
					spi_value <= data_in;
					rd <= '0';
					feed_me <='0';
				end if;
				if (read_me = '1') then
					data_out <= spi_readvalue;
					read_me <='0';
					wr <= '0';
				end if;
			end if;
		end if;
	end process ;

end Behavioral;

