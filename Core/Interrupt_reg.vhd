library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Interrupt_reg is
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
		BUS_Data_in : in std_logic_vector(7 downto 0);
		BUS_Data_out : out std_logic_vector(7 downto 0)
	);
end entity;

architecture arch of Interrupt_reg is

signal Int_flag : std_logic_vector(7 downto 0) := "00000000"; 		--stores flags
signal Int_enable : std_logic_vector(7 downto 0) := "00000000"; 	--stores interrupt authorizations

begin
	
with (Int_flag and Int_enable) select --sends interrupt request to Fetch_Decode if a flag is present and the interrupt is enabled
	Interrupt_out 	<= 	'0' when "00000000",
								'1' when others;

process(Clk, Reset_n)
	variable  Bus_interrupt_flag : std_logic_vector(7 downto 0) := "11111111"; --stores the new value for the flag register
	begin
		if(Reset_n = '0') then
			Int_flag <= "00000000";
			Int_enable <= "00000000"; 
		elsif(falling_edge(Clk)) then
			Bus_interrupt_flag  := "11111111"; --default value for Bus_interrupt_flag
			
			--Data_bus_handling
			if(to_integer(unsigned(BUS_address(15 downto 0))) = Interrupt_flag_address) then 
				if(Bus_address(16) = '0') then
					Bus_interrupt_flag := Bus_data_in;
				else
					Bus_Data_out <= Int_flag;
				end if;
			elsif(to_integer(unsigned(BUS_address(15 downto 0))) = Interrupt_enable_address) then
				if(Bus_address(16) = '0') then
					Int_enable <= Bus_data_in;
				else
					Bus_Data_out <= Int_enable;
				end if;
			end if;
			
			--interrupt input handling
			Int_flag <= (Int_flag and Bus_interrupt_flag) or Interrupt_input; 
		end if;
	end process;

end arch;