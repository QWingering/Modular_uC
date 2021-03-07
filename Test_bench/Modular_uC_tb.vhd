library ieee;
use ieee.std_logic_1164.all;

entity Modular_uC_tb is
end entity;

architecture bhv of Modular_uC_tb is

component Modular_uC is
	PORT
	(
		Clk :  IN  STD_LOGIC;
		Reset_n :  IN  STD_LOGIC;
		Bus_data :  INOUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		Interrupt_input :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		Bus_address :  OUT  STD_LOGIC_VECTOR(16 DOWNTO 0)
	);
end component;

signal Clk : std_logic := '0';
signal Reset_n : std_logic := '1';
signal Bus_data  : std_logic_vector (7 downto 0);
signal Interrupt_input : std_logic_vector(7 downto 0) :="00000000";
signal Bus_address : std_logic_vector(16 downto 0);

begin

	DUT1 : entity work.Modular_uC(bdf_type)
		port map(
			Clk => Clk,
			Reset_n => Reset_n,
			Bus_data => Bus_data,
			Interrupt_input => Interrupt_input,
			Bus_address => Bus_address
			);
	
	process
		begin
			wait for 1 ns;
			Clk <= not(Clk);
		end process;
		

end bhv;