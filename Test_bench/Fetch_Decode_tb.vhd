library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fetch_Decode_tb is
end entity;

architecture bhv of Fetch_Decode_tb is

	component Fetch_Decode is
		generic(
			INSTR_ROM_SIZE : integer := 16
		);
		port(
			Clk : in std_logic;
			Reset_n : in std_logic;
			
			instr_Data : in std_logic_vector(23 downto 0);
			instr_Add  : out std_logic_vector((INSTR_ROM_SIZE-1) downto 0);
			
			Stack_Add_in : in std_logic_vector((INSTR_ROM_SIZE-1) downto 0);
			Stack_Add_out : out std_logic_vector((INSTR_ROM_SIZE-1) downto 0);
			Stack_read_element : out std_logic;
			Stack_add_element : out std_logic;
			
			Bus_address : out std_logic_vector(16 downto 0);
			
			Alu_Test_Zero : in std_logic;
			Alu_op_code : out std_logic_vector(3 downto 0);
			
			Int_Interrupt_in : in std_logic;

			Data_out : out std_logic_vector(7 downto 0);
			
			Reg_input_mux : out std_logic_vector(1 downto 0);
			Reg_Control : out std_logic_vector(16 downto 0)
		);
	end component;

	signal Clk : std_logic := '0';
	signal Reset_n : std_logic := '1';
	
	signal instr_Data : std_logic_vector(23 downto 0) := (others => '0');
	signal instr_Add : std_logic_vector(15 downto 0);
	
	signal Stack_add_in : std_logic_vector(15 downto 0);
	signal Stack_add_out : std_logic_vector(15 downto 0);
	signal Stack_add_element : std_logic;
	signal Stack_read_element : std_logic;
	
	signal Bus_address : std_logic_vector(16 downto 0);
	
	signal Alu_Test_Zero : std_logic;
	signal Alu_op_code : std_logic_vector(3 downto 0);
	
	signal Int_Interrupt_in : std_logic;
	
	signal Data_out : std_logic_vector(7 downto 0);
	
	signal Reg_input_mux : std_logic_vector(1 downto 0);
	signal Reg_Control : std_logic_vector (16 downto 0);

begin

	DUT1: entity work.Fetch_Decode(arch)
		port map(	
				clk => Clk, 
				Reset_n => Reset_n, 
				instr_Data => instr_Data, 
				instr_Add => instr_Add, 
				Stack_add_out => Stack_add_out, 
				Stack_Add_in => Stack_Add_in,
				Stack_add_element => Stack_add_element,
				Stack_read_element => Stack_read_element,
				Bus_address => Bus_address,
				Alu_Test_Zero => Alu_Test_Zero,
				Alu_op_code => Alu_op_code,
				Int_Interrupt_in => Int_Interrupt_in,
				Data_out => Data_out,
				Reg_input_mux => Reg_input_mux,
				Reg_Control => Reg_Control
				);
	
	process
	begin
		wait for 1 ns;
		Clk <= not(Clk);
	end process;
	
	process
	begin
		wait for 9 ns; 
		instr_Data <= ('0','0','0','1', others => '0');
		wait for 8 ns;
		instr_Data <= "010100001000000000000000";
		wait for 8 ns;
		instr_Data <= "010010101010101010101010";
		wait for 1 ms;
	end process;
	
end bhv;