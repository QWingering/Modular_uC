library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Bus_interface_master is
port(
	BUS_data_out : out std_logic_vector(7 downto 0);
	BUS_data_in : in std_logic_vector(7 downto 0);
	BUS_address : out std_logic_vector(16 downto 0); --MSB : 0 if master is writing, 1 if master is reading
	Clk : in std_logic;
	Reset_n : in std_logic;
	Data_in : in std_logic_vector(7 downto 0);
	Data_out : out std_logic_vector(7 downto 0);
	Address : in std_logic_vector(16 downto 0)
);
end entity;

architecture arch of Bus_interface_master is 

	signal tmp_Bus_address : std_logic_vector(16 downto 0);

begin

	process(Clk, Reset_n)
	begin
		if(Reset_n = '0') then
			
		elsif(rising_edge(Clk)) then
			tmp_Bus_address <= Address;
			if(tmp_Bus_address(16) = '1') then --master was reading, need to store data and stay in HighZ
				Data_out <= BUS_data_in;
			else
				if(Address(16) = '0') then --master is writing
					if(to_integer(unsigned(Address)) = 0) then --nothing to send, put the bus to 0
						Bus_data_out <= "00000000";
					else
						Bus_data_out <= Data_in;
					end if;
				end if;
			end if;
		end if;
	end process;
	BUS_address <= tmp_Bus_address;

end arch;