-------------------------------------------------
-- Project : SPI FIR       		              --
-- Author : Emiliano Sisinni                   --
-- Date : AY2022/2023                          --
-- Company : UniBS                             --
-- File : coeffs_package.vhd   		           --
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package coeffs_package is
	-- Filter length = number of taps = number of coefficients = order + 1
	type coeff_vector is array(natural range <>) of signed(15 downto 0);		
	
	-- Filter coefficient can be computed using Matlab "filterDesigner" tool
	-- If sampling frequency is Fs; number of FFT points is NFFT, analog  frequency is freq 
	-- discrete frequency is Freq = (NFFT/Fs)*freq
	-- Fs = 100Sa/s; Fpass = 10Hz; Fstop = 25Hz; Apass=1dB; Astop=50dB; Order = 10
	-- If normalized, Wpass = 2*(Fpass/Fs) = 0.2, Wstop = 2*(Fstop/Fs) = 0.5
	-- Scale by 2^15 * 2:
	-- Coeff (signed Q15): {-949,  -1034,   2029,   9203,  17325,  20944,  17325,   9203,   2029, -1034,   -949};

--	constant b: coeff_vector(0 to 10):=(
--		x"fc4b",
--		x"fbf6",
--		x"07ed",
--		x"23f3",
--		x"43ad",
--		x"51d0",
--		x"43ad",
--		x"23f3",
--		x"07ed",
--		x"fbf6",
--		x"fc4b"
--	);

	constant b: coeff_vector(0 to 3):=(
		x"FFFF",
		x"0000",
		x"0000",
		x"0000"
	);

end package coeffs_package;