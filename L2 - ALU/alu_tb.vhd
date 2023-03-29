--! Project : Simple Arithmetic Logic Unit    
--! <br>               
--! Author : Emiliano Sisinni                   
--! <br>               
--! Date : AY2022/2023                          
--! <br>               
--! Company : UniBS                             
--! <br>               
--! File : alu_tb.vhd  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu_tb is
end alu_tb;

architecture alu_tb_arch of alu_tb is
  component alu port (
    Accumulator_in : in std_logic_vector (7 downto 0);
    Data_in        : in std_logic_vector (7 downto 0);
    Opcode_in      : in std_logic_vector (3 downto 0);
    Result_out     : out std_logic_vector (7 downto 0));
  end component;

  signal Accumulator : std_logic_vector (7 downto 0);
  signal Data        : std_logic_vector (7 downto 0);
  signal Opcode      : std_logic_vector (3 downto 0);
  signal Result      : std_logic_vector (7 downto 0);

begin

  dut1 : ALU port map(
    Accumulator_in => Accumulator,
    Data_in        => Data,
    Opcode_in      => Opcode,
    Result_out     => Result);

  operation_1 : process
  begin
    wait for 0 ns;
    Opcode <= "0000";
    wait for 1 ns;
    assert (Result = Data) report "Error Opcode 0000" severity error;
    wait for 10 ns;
    Opcode <= "0001";
    wait for 1 ns;
    assert (Result = Accumulator) report "Error Opcode 0001" severity error;
    wait for 10 ns;
    Opcode <= "0010";
    wait for 1 ns;
    assert (Result = "00001011") report "Error Opcode 0010" severity error;
    wait for 10 ns;
    Opcode <= "0011";
    wait for 1 ns;
    assert (Result = "00001001") report "Error Opcode 0011" severity error;
    wait for 10 ns;
    Opcode <= "0100";
    wait for 1 ns;
    assert (Result = (Accumulator and Data)) report "Error Opcode 0100" severity error;
    wait for 10 ns;
    Opcode <= "0101";
    wait for 1 ns;
    assert (Result = (Accumulator or Data)) report "Error Opcode 0101" severity error;
    wait for 10 ns;
    Opcode <= "0110";
    wait for 1 ns;
    assert (Result = (Accumulator xor Data)) report "Error Opcode 0110" severity error;
    wait for 10 ns;
    Opcode <= "0111";
    wait for 1 ns;
    assert (Result = (not(Accumulator))) report "Error Opcode 0111" severity error;
    wait for 10 ns;
    Opcode <= "1000";
    wait for 1 ns;
    assert (Result = (not(Data))) report "Error Opcode 1000" severity error;
    wait for 10 ns;
    Opcode <= "1001";
    wait for 1 ns;
    assert (Result = "00000000") report "Error Opcode 1001" severity error;
    wait for 10 ns;
    Opcode <= "1010";
    wait for 1 ns;
    assert (Result = "00010100") report "Error Opcode 1010" severity error;
    wait for 10 ns;
    Opcode <= "1011";
    wait for 1 ns;
    assert (Result = "00000101") report "Error Opcode 1011" severity error;
    wait for 10 ns;
    Opcode <= "1100";
    wait for 1 ns;
    assert (Result = (Accumulator nand Data)) report "Error Opcode 1100" severity error;
    wait for 10 ns;
    Opcode <= "1101";
    wait for 1 ns;
    assert (Result = (Accumulator nor Data)) report "Error Opcode 1101" severity error;
    wait for 10 ns;
    Opcode <= "1110";
    wait for 1 ns;
    assert (Result = (Accumulator xnor Data)) report "Error Opcode 1110" severity error;
    wait for 10 ns;
    Opcode <= "1111";
    wait for 1 ns;
    assert (Result = "00001011") report "Error Opcode 1111" severity error;
    wait;
  end process operation_1;

  operation_2 : process
  begin
    wait for 0 ns;
    Data <= "00000001";
    wait;
  end process operation_2;

  operation_3 : process
  begin
    wait for 0 ns;
    Accumulator <= "00001010";
    wait;
  end process operation_3;
end alu_tb_arch;