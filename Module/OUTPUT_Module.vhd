library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity OUTPUT_Module is
	generic(
		SIZE : integer := 1;
		base_address : integer := 1
	);
	port(
		BUS_data_in : in std_logic_vector(7 downto 0);
		BUS_data_out : out std_logic_vector(7 downto 0);
		BUS_address : in std_logic_vector(16 downto 0); --MSB : 0 if master is writing, 1 if master is reading
		Output : out std_logic_vector(7 downto 0);
		Clk : in std_logic;
		Reset_n : in std_logic
	);
end entity;

architecture arch of OUTPUT_Module is

signal oe : std_logic;
signal tmp_out : std_logic_vector(7 downto 0);

begin
	BUS_interf: process(Clk)
	variable tmp : std_logic_vector(7 downto 0) := "00000000";
		begin
			if(falling_edge(Clk)) then
				
				if(to_integer(unsigned(BUS_address(15 downto 8))) = base_address) then 			--if this slave has been addressed
					if(oe = '0') then 					--master is writing
						tmp_out <= BUS_data_in;
					else
						BUS_data_out <= tmp_out;
					end if;
				end if;
				
			end if;
		end process;
		oe <= BUS_address (16);
		Output <= tmp_out;
		
end arch;