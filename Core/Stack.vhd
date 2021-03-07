library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stack is
generic(
	STACK_SIZE : integer := 16;
	INSTRUCTION_ADD_SIZE : integer := 16 
);
port(
	Instr_add_in : in std_logic_vector(INSTRUCTION_ADD_SIZE-1 downto 0);
	Instr_add_out : out std_logic_vector (INSTRUCTION_ADD_SIZE-1 downto 0);
	
	Reset_n : in std_logic;
	CLK : in std_logic;				
	
	Add_element: in std_logic;		--add element to the stack
	Read_element : in std_logic	--read element from the stack
);
end entity;



architecture arch of Stack is

type INTERNAL_MEMORY is array (0 to (STACK_SIZE-1)) of std_logic_vector((INSTRUCTION_ADD_SIZE-1) downto 0);

signal stack : INTERNAL_MEMORY := (others => (others => '0')); --memoire du stack

begin
	
	process(Reset_n, CLK)
	variable pointer : integer range 0 to (STACK_SIZE-1):= 0;
		begin
			if(Reset_n = '0') then
				pointer := 0;
				stack <= (others => (others =>'0'));
			elsif(rising_edge(CLK)) then
				if(Add_element = '1') then 				--add element
					if(pointer = STACK_SIZE-1) then
						pointer := 0; 									--Stack is full...
					else
						pointer := pointer + 1;						--increase pointer
						stack(pointer) <= Instr_add_in;			--load new element
					end if;
				elsif(Read_element = '1') then 			--read element
					if(pointer = 0) then							--stack is empty... impossible to read
						pointer := 0; 									
						Instr_add_out <= (others => '0'); 		--send the 0x0 adress
					else
						Instr_add_out <= stack(pointer);			-- read element
						pointer := pointer - 1;						-- decrease pointer
					end if;
				end if;
			end if;
		end process;
end arch;