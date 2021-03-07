library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Bus_interface_master_tb is
end entity;

architecture bhv of Bus_interface_master_tb is

	component Bus_interface_master is
	port(
		BUS_data : inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
		BUS_address : out std_logic_vector(16 downto 0); --MSB : 0 if master is writing, 1 if master is reading
		Clk : in std_logic;
		Reset_n : in std_logic;
		Data_in : in std_logic_vector(7 downto 0);
		Data_out : out std_logic_vector(7 downto 0);
		Address : in std_logic_vector(16 downto 0)
	);
	end component;

	component RAM_Module is
	generic(
		SIZE : integer := 256;
		base_address : integer := 1
	);
	port(
		BUS_data : inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
		BUS_address : in std_logic_vector(16 downto 0); --MSB : 0 if master is writing, 1 if master is reading
		Clk : in std_logic
	);
	end component;
	
	
	signal BUS_data : std_logic_vector(7 downto 0) := "ZZZZZZZZ";
	signal BUS_address : std_logic_vector(16 downto 0) := (others => '0');
	signal Clk: std_logic := '0';
	signal Reset_n : std_logic := '1';
	signal Data_in : std_logic_vector(7 downto 0) := (others => '0');
	signal Data_out : std_logic_vector(7 downto 0);
	signal Address : std_logic_vector(16 downto 0) := (others => '0');
	
begin
	
	DUT1 : entity work.Bus_interface_master(arch)
		port map( BUS_data => BUS_data, BUS_address => BUS_address, Clk => Clk, Reset_n => Reset_n, Data_in => Data_in, Data_out => Data_out, Address => Address);
	
	RAM : entity work.RAM_Module(arch)
		port map(BUS_data => BUS_data, BUS_address => Bus_address, Clk => Clk);
		
	process
		variable counter : integer range 0 to 100:= 0;
		begin
			wait for 1 ns;
			Clk <= not(Clk);
			if(counter = 0)then
				
			elsif(counter = 1) then
				Address <= "00000000100000000"; --write to register 0 of ram
				Data_in <= "01010100";
			elsif (counter = 5) then
				Address <= "10000000100000000"; --reading from register 0 of ram
			elsif(counter = 3 or counter = 7) then
				Address <= (others => '0');
			end if;
			if(counter = 7) then
				counter := 0;
			else
				counter := counter + 1;
			end if;
		end process;
	
end bhv;