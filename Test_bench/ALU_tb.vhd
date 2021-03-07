library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end entity;

architecture bhv of ALU_tb is

	component ALU is
	port(
		A : in std_logic_vector(7 downto 0); 
		B : in std_logic_vector(7 downto 0); 
		Operator : in std_logic_vector(3 downto 0);
		S : out std_logic_vector(7 downto 0);
		Reset_n : in std_logic;
		CLK : in std_logic;
		Test_Zero_out : out std_logic;
		
		BUS_address : in std_logic_vector(16 downto 0);
		BUS_Data : out std_logic_vector(7 downto 0) := "ZZZZZZZZ"
	);
	end component;

	signal A, B, S : std_logic_vector(7 downto 0) := "10011111";
	signal operator : std_logic_vector(3 downto 0) :="0000";
	signal reset_n, Clk : std_logic := '1';
	signal Test_Zero_out : std_logic;
	signal BUS_address : std_logic_vector(16 downto 0) := (others => '0');
	signal BUS_data : std_logic_vector(7 downto 0);
	
begin

	DUT1 : entity work.ALU(arch)
		port map(A => A, B => B, Operator => Operator, S => S, Reset_n => Reset_n, Clk => Clk, Test_zero_out => Test_zero_out, BUS_address => BUS_address, BUS_data => BUS_data);

	process
		begin
			wait for 10 ns;
				Operator <= std_logic_vector(unsigned(Operator)+1);
		end process;
end bhv;