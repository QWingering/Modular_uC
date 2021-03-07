library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Work_reg is
port(
	Reg_Data_out 	: out std_logic_vector(7 downto 0);		--Data output
	Reg_Data_out_A : out std_logic_vector(7 downto 0);		--Data output to A input of ALU
	Reg_Data_out_B : out std_logic_vector(7 downto 0);		--Data output to B input of ALU
	Reg_Data_in 	: in 	std_logic_vector(7 downto 0);		--Data input
	Reg_Control 	: in 	std_logic_vector(16 downto 0);	--Data output address control
	
	CLK 		: in std_logic;
	Reset_n 	: in std_logic
);
end Work_reg;

architecture arch of Work_reg is

type INTERNAL_MEMORY is array (0 to 15) of std_logic_vector(7 downto 0);

signal memory : INTERNAL_MEMORY := (others => "00000000");

begin

	Reg_Data_out		<= memory(to_integer(unsigned(Reg_Control(3 downto 0)))); 
	Reg_Data_out_B 	<= memory(to_integer(unsigned(Reg_Control(7 downto 4)))); 
	Reg_Data_out_A 	<= memory(to_integer(unsigned(Reg_Control(11 downto 8)))); 
	
	process(CLK, Reset_n)
		begin
			if(Reset_n = '0') then
				memory <= (others => "00000000");
			elsif(rising_edge(CLK)) then 				--data is written on a rising clock edge
				if(Reg_control(16) = '1') then 			--Write enable
					memory(to_integer(unsigned(Reg_Control(15 downto 12)))) <= Reg_Data_in;
				end if;
			end if;
		end process;
	
end arch;