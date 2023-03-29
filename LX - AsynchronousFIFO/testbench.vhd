--! Project : Asynchronous FIFO    
--! Author : Emiliano Sisinni                 
--! Date : AY2022/2023                        
--! Company : UniBS                           
--! File : testbench.vhd 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY asynchronFIFOasymmetricPorts_TB IS
END asynchronFIFOasymmetricPorts_TB;
 
ARCHITECTURE behavior OF asynchronFIFOasymmetricPorts_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT async_fifo
    generic (
       B: natural :=8;
   	   DEPTH: natural:=4
    );
    port (
      clkw: in std_logic;
      resetw: in std_logic;
      wr: in std_logic;
      full: out std_logic;
      dataw: in std_logic_vector (B-1 downto 0);
      clkr: in std_logic;
      resetr: in std_logic;
      rd: in std_logic;
      empty: out std_logic;
      datar: out std_logic_vector (B-1 downto 0)
    );
	END COMPONENT;
    

   --Inputs
   signal resetR : std_logic := '0';
   signal resetW : std_logic := '0';
   signal clockR : std_logic := '0';
   signal clockW : std_logic := '0';
   signal enR : std_logic := '0';
   signal enW : std_logic := '0';
   signal dataW : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
   signal emptyR : std_logic;
   signal fullW : std_logic;
   signal datar : std_logic_vector(7 downto 0);


   -- Clock period definitions
   constant clockR_period : time := 16 ns;
   constant clockW_period : time := 12.5 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: async_fifo PORT MAP (
          resetw => resetW,
          resetr => resetR,
          clkr => clockR,
          clkw => clockW,
          rd => enR,
          Wr => enW,
          empty => emptyR,
          full => fullW,
          dataw => dataW,
          datar => datar
        );

   -- Clock process definitions
   clockR_process :process
   begin
        clockR <= '0';
        wait for clockR_period/2;
        clockR <= '1';
        wait for clockR_period/2;
   end process;
 
   clockW_process :process
   begin
        clockW <= '0';
        wait for clockW_period/2;
        clockW <= '1';
        wait for clockW_period/2;
   end process;
 
   -- Stimulus process
   stim_proc_reset: process
   begin        
      -- hold reset state for 100 ns.
        resetR <= '1';
        resetW <= '1';
      wait for 100 ns;  
        resetR <= '0';
        resetW <= '0';
      wait;
   end process;

   stim_proc_write: process
   begin        
      wait for 100 ns;  
      -- insert stimulus here
      wait for clockW_period*10;
        enW <= '1';
        dataW <= x"ad";
      wait for clockW_period;
        dataW <= x"ef";
      wait for clockW_period;
        enW <= '0';
      wait for clockW_period*30;
        enW <= '1';
        dataW <= x"ab";
      wait for clockW_period;
        dataW <= x"cd";
      wait for clockW_period*40;
        enW <= '0';
      wait;
   end process;
    
   stim_proc_read: process
   begin        
      wait for 100 ns;  
      -- insert stimulus here
      wait for clockR_period*20;
        enR <= '1';
      wait for clockR_period*8;
      enR <= '0';
      wait for clockR_period*8;
      enR <= '1';
        wait;
   end process;

END;