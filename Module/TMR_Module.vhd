library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TMR_Module is
	generic(
		base_address : integer := 1
	);
	port(
		BUS_data_in : in std_logic_vector(7 downto 0);
		BUS_data_out : out std_logic_vector(7 downto 0);
		BUS_address : in std_logic_vector(16 downto 0); --MSB : 0 if master is writing, 1 if master is reading
		Interrupt_out : out std_logic;
		
		Clk : in std_logic;
		Reset_n : in std_logic
	);
end entity;

architecture arch of TMR_Module is

constant SIZE : integer := 2;

type INTERNAL_MEMORY is array (0 to (SIZE-1)) of std_logic_vector(7 downto 0);

signal memory : INTERNAL_MEMORY := (others => "00000000");
signal update_register : std_logic_vector(7 downto 0);
signal update_register_number : std_logic_vector(7 downto 0);
signal we : std_logic := '0';

begin

Interface : process(Clk,Reset_n)
begin
	if(falling_edge(Clk)) then
		we <= '0';
		if(to_integer(unsigned(BUS_address(15 downto 8))) = base_address and to_integer(unsigned(BUS_address(7 downto 0)))<SIZE) then --if this slave has been addressed
			if(BUS_address(16) = '0') then 	--Core writes to module
				update_register <= BUS_data_in;
				update_register_number <= BUS_address(7 downto 0);
				we <= '1';
			else	--module writes to core
				BUS_data_out <= memory(to_integer(unsigned(BUS_address(7 downto 0))));
			end if;
		end if;
	end if;
end process;

process(Clk, Reset_n)
variable internal_counter : integer range 0 to 65535;
begin
	if (Reset_n = '0') then
		memory <= (others => (others => '0'));
		internal_counter := 0;
		Interrupt_out <= '0';
	elsif(rising_edge(Clk)) then
		if(we = '1') then
			memory(to_integer(unsigned(update_register_number))) <= update_register;
		else 
			if(internal_counter >= (2**(to_integer(unsigned(memory(1)(3 downto 0)))+2))-1) then --time to increment tmr counter register
				internal_counter := 0;
				memory(0) <= std_logic_vector(unsigned(memory(0))+1);
				if(memory(0) = "11111111") then
					Interrupt_out <= '1';
				end if;
			else
				internal_counter := internal_counter + 1;
				if(internal_counter = 2) then --ensures that the core has received the interrupt
					Interrupt_out <= '0';
				end if;
			end if;
		end if;
	end if;
end process;
	
end arch;