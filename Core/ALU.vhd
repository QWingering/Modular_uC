library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		A : in std_logic_vector(7 downto 0); 			--input A
		B : in std_logic_vector(7 downto 0); 			--input B
		Operator : in std_logic_vector(3 downto 0);	--operator
		S : out std_logic_vector(7 downto 0);			--Output
		Reset_n : in std_logic;								--Reset pin (not used)
		CLK : in std_logic;									--Clk in (not used)
		Test_Zero_out : out std_logic						--Outputs 1 when the output is 0, used to skip instructions
		
	);
end entity;

architecture arch of ALU is

signal result : std_logic_vector (8 downto 0) := "000000000";
signal Test_zero : std_logic 		:= '0';
signal Overflow_bit : std_logic 	:= '0';

begin
		

	
	with operator select
		result<= 	'0' & A when "0000",	
						'0' & (A and B) when "0001", 										-- AND
						'0' & (A OR B) when "0010",  										-- OR
						'0' & (A XOR B) when "0011",										-- XOR
						'0' & (NOT A) when "0100",											-- NOT
						'0' & (A(6 downto 0) & A(7)) when "0101",	 					-- rotation 
						'0' & (A(0) & A(7 downto 1)) when "0110",						-- rotation 
						'0' & (A(6 downto 0) & '0') when "0111",						-- shift 
						"00" & (A(7 downto 1)) when "1000",								-- shift 
						(std_logic_vector(to_unsigned((to_integer(unsigned(A))+to_integer((unsigned(B)))),9))) when "1001",-- addition
						(std_logic_vector(to_unsigned((to_integer(unsigned(A))-to_integer((unsigned(B)))),9))) when "1010",-- substraction
						'0' & (std_logic_vector(unsigned (A) - 1)) when "1011",				-- decrementation of A														
						'0' & A when others;
	
	with result(7 downto 0) select
		Test_zero <= 	'1' when "00000000",
							'0' when others;
	
	
	Overflow_bit <= result(8);  --unused (for now...)
	Test_Zero_out <= Test_zero; --used by Fetch_decode to skip instructions
	S <= result(7 downto 0);	 --result
	
end arch;