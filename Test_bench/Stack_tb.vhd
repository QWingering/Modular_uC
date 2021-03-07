library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Stack_tb is
end entity;

architecture bhv of Stack_tb is

	component Stack is
		generic(
			STACK_SIZE : integer := 16;
			INSTRUCTION_ADD_SIZE : integer := 16 
		);
		port(
			Instr_add_in : in std_logic_vector(INSTRUCTION_ADD_SIZE-1 downto 0);
			Instr_add_out : out std_logic_vector (INSTRUCTION_ADD_SIZE-1 downto 0);
			
			Reset_n : in std_logic;
			CLK : in std_logic;				
			
			Add_element: in std_logic;		--permet d'empiler un élément
			Read_element : in std_logic	--permet de retirer un élément de la pile
		);
	end component;

	signal Inst_add_in : std_logic_vector(15 downto 0) := ('1', '0', others => '1');
	signal Inst_add_out : std_logic_vector(15 downto 0);
	
	signal Reset_n : std_logic := '1';
	signal CLK : std_logic := '0';
	
	signal Add_element : std_logic := '0';
	signal Read_element : std_logic := '0';
	
	
begin

	DUT1: entity work.Stack(arch)
		port map(Instr_add_in => Inst_add_in, Instr_add_out => Inst_add_out, Reset_n => Reset_n, CLK => CLK, Add_element => add_element, Read_element => Read_element);

	process 
		begin
			wait for 0.5 ns;
			CLK <= not(CLK);
		end process;
	
	process 
		variable cptr : integer := 0;
		begin 
			wait for 1 ns;
			if(cptr = 0) then
				Add_element <= '1';
				Read_element <= '0';
				cptr := 1;
			else
				cptr := 0;
				Add_element <= '0';
				Read_element <= '1';
				Inst_add_in <= std_logic_vector(unsigned(Inst_add_in) + 1);
			end if;
		end process;

end bhv;