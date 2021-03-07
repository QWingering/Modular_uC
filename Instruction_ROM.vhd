library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Instruction_ROM is
generic(
	INSTR_SIZE : integer := 24;
	ROM_SIZE   : integer := 16
);
port(
	address : in std_logic_vector((ROM_SIZE-1) downto 0);
	CLK : in std_logic;
	Reset_n : in std_logic;
	Data_out : out std_logic_vector((INSTR_SIZE-1) downto 0)
	);
end entity; 

architecture arch of Instruction_ROM is

	type INTERNAL_MEMORY is array (0 to (2**(ROM_SIZE))-1) of std_logic_vector((INSTR_SIZE-1) downto 0); --stores the program

	constant memory : INTERNAL_MEMORY := (
													"011100000000000011111111",
													"011000000000000100000000",
													"100000000000000011111011",
													"000100000000000000000001",
													"010100010000001000000000",
													"100000000001000100000000",
													"000100000000000000000100",
													"000100000000000000000000",

													others => (others => '0' )
													);
													
	signal internal_address : std_logic_vector((ROM_SIZE-1) downto 0);

begin
	
	process(CLK, Reset_n)
		begin
			if(Reset_n = '0') then
				internal_address <= (others => '0');
			elsif (rising_edge(CLK)) then --on rising edge, update the internal_address pointer
				internal_address <= address;
			end if;
		end process;
	
	Data_out <= memory(to_integer(unsigned(internal_address)));
	
end arch;