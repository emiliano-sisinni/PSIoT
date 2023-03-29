--! Project : Simple Arithmetic Logic Unit    
--! <br>               
--! Author : Emiliano Sisinni                   
--! <br>               
--! Date : AY2022/2023                          
--! <br>               
--! Company : UniBS                             
--! <br>               
--! File : alu.vhd                            

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ALU is
  port (
    Accumulator_in : in std_logic_vector (7 downto 0);
    Data_in        : in std_logic_vector (7 downto 0);
    Opcode_in      : in std_logic_vector (3 downto 0);
    Result_out     : out std_logic_vector (7 downto 0)
  );
end ALU;

architecture ALU_arch of ALU is
begin
  Main : process (Accumulator_in, Opcode_in, Data_in)
  begin
    case Opcode_in is

        --! Operations implemented by the ALU
        --! result = Data_in
      when "0000" => Result_out <= Data_in;
        --! result = accumulator_in
      when "0001" => Result_out <= Accumulator_in;
        --! result = accumulator_in + Data_in
      when "0010" => Result_out <= std_logic_vector(unsigned(Accumulator_in) + unsigned(Data_in));
        --! result = accumulator_in - Data_in
      when "0011" => Result_out <= std_logic_vector(unsigned(Accumulator_in) - unsigned(Data_in));
        --! result = accumulator_in and Data_in
      when "0100" => Result_out <= Accumulator_in and Data_in;
        --! result = accumulator_in or Data_in
      when "0101" => Result_out <= Accumulator_in or Data_in;
        --! result = accumulator_in xor Data_in
      when "0110" => Result_out <= Accumulator_in xor Data_in;
        --! result = not(accumulator_in)
      when "0111" => Result_out <= not(accumulator_in);
        --! result = not(Data_in);
      when "1000" => Result_out <= not(Data_in);
        --! result = 0
      when "1001" => Result_out <= "00000000";
        --! result = shift left 1pos accumulator_in
      when "1010" => Result_out <= std_logic_vector(shift_left(unsigned(Accumulator_in), 1));
        --! result = shift right 1pos accumulator_in
      when "1011" => Result_out <= std_logic_vector(shift_right(unsigned(Accumulator_in), 1));
        --! result = accumulator_in nand Data_in
      when "1100" => Result_out <= accumulator_in nand Data_in;
        --! result = accumulator_in nor Data_in
      when "1101" => Result_out <= accumulator_in nor Data_in;
        --!result=accumulator_in xnor Data_in
      when "1110" => Result_out <= accumulator_in xnor Data_in;
        --!result=Accumulator_in+1
      when "1111" => Result_out <= std_logic_vector(unsigned(Accumulator_in) + 1);
      when others => Result_out <= "XXXXXXXX";
    end case;
  end process Main;
end ALU_arch;