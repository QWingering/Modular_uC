library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM_Module is 
generic(
	SIZE : integer := 256;
	base_address : integer := 1
);
port(
	BUS_data : inout std_logic_vector(7 downto 0) := "ZZZZZZZZ";
	BUS_address : in std_logic_vector(16 downto 0); --MSB : 0 if master is writing, 1 if master is reading
	Clk : in std_logic;
	Reset_n : in std_logic
);
end entity;

architecture arch of RAM_Module is

type INTERNAL_MEMORY is array (0 to (SIZE)-1) of std_logic_vector(7 downto 0);

signal memory : INTERNAL_MEMORY := (others => "00000000");

begin
	BUS_interf: process(Clk, Reset_n)
		begin
			if(Reset_n = '0') then
				memory <= (others => "00000000");
			elsif(falling_edge(Clk)) then
				if(to_integer(unsigned(BUS_address(15 downto 8))) = base_address) then 			--if this slave has been addressed
					if(BUS_address(16) = '0') then 					--master is writing
						BUS_data <= "ZZZZZZZZ";							--stay in high z
						memory(to_integer(unsigned(BUS_address(7 downto 0)))) <= BUS_data;  		--stores the data
					else
						BUS_data <= memory(to_integer(unsigned(BUS_address(7 downto 0))));		--slave is writing, sends data to bus
					end if;
				else
					BUS_data <= "ZZZZZZZZ";			-- if this slave has not been addressed, go to high z state
				end if;
			end if;
		end process;
end arch;