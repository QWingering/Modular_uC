library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Interrupt_reg_tb is
end entity;

architecture bhv of Interrupt_reg_tb is

	component Interrupt_reg is
		generic(
			Interrupt_flag_address : integer := 2; --BUS address of the interrupt flag register
			Interrupt_enable_address : integer := 3 --BUS address of the interrupt enable register
		);
		port(
			Interrupt_input : in std_logic_vector(7 downto 0);
			
			Clk : in std_logic;
			Reset_n : in std_logic;
			
			Interrupt_out : out std_logic;
			
			BUS_address : in std_logic_vector(16 downto 0);
			BUS_Data : inout std_logic_vector(7 downto 0) := "ZZZZZZZZ"
		);
	end component;

	signal Interrupt_input : std_logic_vector(7 downto 0) := "00000000";
	signal Clk : std_logic :='0';
	signal Reset_n : std_logic := '1';
	signal Interrupt_out : std_logic;
	signal Bus_address : std_logic_vector(16 downto 0);
	signal Bus_data : std_logic_vector(7 downto 0);
	
begin

	DUT1 : entity work.Interrupt_reg
		port map(
					Interrupt_input => Interrupt_input, 
					Clk => Clk, 
					Reset_n => Reset_n, 
					Interrupt_out => Interrupt_out, 
					Bus_address => Bus_address, 
					Bus_data => Bus_data
					);

	process
		begin
			wait for 1 ns;
			clk <= not(clk);
		end process;
		
	process
		begin
			wait for 1 ns;
			BUS_address <= "00000000000000011";
			BUS_data <= "11111111";
			wait for 2 ns;
			BUS_address <= "00000000000000000";
			BUS_data <= "00000000";
			wait for 2 ns;
			Interrupt_input <= "10000000";
			wait for 2 ns;
			Interrupt_input <= "00000100";
			wait for 2 ns;
			Interrupt_input <= "00000000";
			BUS_address <= "10000000000000010";
			BUS_data <= "ZZZZZZZZ";
			wait for 2 ns;
			BUS_address <= "00000000000000000";
			wait for 2 ns;
			BUS_address <= "00000000000000010";
			BUS_data <= "00000000";
			wait for 2 ns;
			BUS_address <= "00000000000000000";
			BUS_data <= "00000000";
			wait for 10 ms;
			
		end process;
end bhv;