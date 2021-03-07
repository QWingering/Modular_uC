library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Core is
	generic(
		INSTR_ROM_SIZE : integer := 16
	);
	port(
		Clk: in std_logic;
		Reset_n : in std_logic;
		
		Bus_address : out std_logic_vector(16 downto 0); 
		Bus_data_out : out std_logic_vector(7 downto 0);
		Bus_data_in : in std_logic_vector(7 downto 0);
		
		Interrupt_input : in std_logic_vector(7 downto 0);
		
		Instr_address : out std_logic_vector((INSTR_ROM_SIZE-1) downto 0);
		Instr_data : in std_logic_vector(23 downto 0)
	);
end entity;

architecture arch of Core is 

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
			
			Alu_Test_Zero : in std_logic; --if the output of the ALU is 0, then this goes to 1
			Alu_op_code : out std_logic_vector(3 downto 0); --operation code
			
			Int_Interrupt_in : in std_logic; --if 1 : interrupt request

			Data_out : out std_logic_vector(7 downto 0); --Data to register
			
			Reg_input_mux : out std_logic_vector(1 downto 0); -- (00 -> nothing, 01 ->  ALU, 10 -> Decode, 11 -> BUS)
			Reg_Control : out std_logic_vector(16 downto 0)
		);
	end component;

	component Work_reg is
		port(
			Reg_Data_out 	: out std_logic_vector(7 downto 0);		--Data output
			Reg_Data_out_A : out std_logic_vector(7 downto 0);		--Data output to A input of ALU
			Reg_Data_out_B : out std_logic_vector(7 downto 0);		--Data output to B input of ALU
			Reg_Data_in 	: in 	std_logic_vector(7 downto 0);		--Data input
			Reg_Control 	: in 	std_logic_vector(16 downto 0);	--Data output address control
			
			CLK 		: in std_logic;
			Reset_n 	: in std_logic
		);
	end component;

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
			
			Add_element: in std_logic;		--add element to the stack
			Read_element : in std_logic	--read element from the stack
		);
	end component;

	component ALU is
		port(
			A : in std_logic_vector(7 downto 0); 
			B : in std_logic_vector(7 downto 0); 
			Operator : in std_logic_vector(3 downto 0);
			S : out std_logic_vector(7 downto 0);
			Reset_n : in std_logic;
			CLK : in std_logic;
			Test_Zero_out : out std_logic
			
		);
	end component;

	component Bus_interface_master is
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
	end component;
	
	component Interrupt_reg is
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
	end component;
	
	signal Stack_Add_Stack_Fetch, Stack_Add_Fetch_Stack : std_logic_vector((INSTR_ROM_SIZE-1) downto 0);
	signal Stack_read_element, Stack_add_element : std_logic;
	
	signal Bus_address_Fetch_Master : std_logic_vector(16 downto 0);
	
	signal Bus_address_internal : std_logic_vector(16 downto 0);
	signal Bus_data_out_internal : std_logic_vector(7 downto 0);
	signal Bus_data_in_internal : std_logic_vector(7 downto 0);
	signal Bus_data_in_from_Interrupt : std_logic_vector(7 downto 0);
	
	signal ALU_Test_Zero : std_logic;
	signal ALU_op_code : std_logic_vector(3 downto 0);
	
	signal Int_interrupt : std_logic;
	
	signal Data_Fetch_MUX : std_logic_vector(7 downto 0);
	
	signal Reg_MUX : std_logic_vector(1 downto 0);
	signal Reg_Control : std_logic_vector(16 downto 0);
	
	signal Reg_Data_out, Reg_Data_out_A, Reg_Data_out_B, Reg_Data_in : std_logic_vector(7 downto 0);
	
	signal ALU_out : std_logic_vector(7 downto 0);
	
	signal Data_bus_MUX : std_logic_vector(7 downto 0);
	
begin
	
	Fetch_Decode_inst : entity work.Fetch_Decode (arch)
		port map(
				Clk => CLK,
				Reset_n => Reset_n,
				
				instr_Data => Instr_data,
				instr_Add => Instr_address,
				
				Stack_Add_in => Stack_Add_Stack_Fetch,
				Stack_Add_out => Stack_Add_Fetch_Stack,
				Stack_read_element => Stack_read_element,
				Stack_add_element => Stack_add_element,
				
				Bus_address => Bus_address_Fetch_Master,
				
				ALU_Test_Zero => ALU_Test_Zero,
				ALU_op_code => ALU_op_code,
				
				Int_Interrupt_in => Int_interrupt,
				
				Data_out => Data_Fetch_MUX,
				
				Reg_input_mux => Reg_MUX,
				Reg_Control => Reg_Control
				);
	
	Work_reg_inst : entity work.Work_reg (arch)
		port map(
				Clk => CLK,
				Reset_n => Reset_n,
				
				Reg_Control => Reg_Control,
				Reg_Data_out => Reg_Data_out,
				Reg_Data_out_A => Reg_Data_out_A,
				Reg_Data_out_B => Reg_Data_out_B,
				Reg_Data_in => Reg_Data_in
				);
					
	Stack_inst : entity work.Stack (arch)
		port map(
				Clk => CLK,
				Reset_n => Reset_n,
				
				Instr_add_in => Stack_Add_Fetch_Stack,
				Instr_add_out => Stack_Add_Stack_Fetch,
				
				Add_element => Stack_add_element,
				Read_element => Stack_read_element
				);
	
	ALU_inst : entity work.ALU (arch)
		port map(
				A => Reg_Data_out_A,
				B => Reg_Data_out_B,
				S => ALU_out,
				
				Operator => Alu_op_code,
				
				Clk => Clk,
				Reset_n => Reset_n,
				
				Test_Zero_out => ALU_Test_Zero
				
				);
					
	Bus_interface_master_inst : entity work.Bus_interface_master(arch)
		port map(
				Clk => Clk,
				Reset_n => Reset_n,
				
				Bus_data_in => BUS_data_in_internal,
				Bus_data_out => BUS_data_out_internal,
				Bus_address => BUS_address_internal,
				
				Data_in => Reg_Data_out,
				Data_out => Data_bus_MUX,
				Address => Bus_address_Fetch_Master
				);
					
	Interrupt_reg_inst : entity work.Interrupt_reg(arch)
		port map(
				Clk => Clk,
				Reset_n => Reset_n,
				
				Interrupt_input => Interrupt_input,
				Interrupt_out => Int_interrupt,
				
				Bus_address => Bus_address_internal,
				Bus_data_in => Bus_data_out_internal,
				Bus_data_out => Bus_data_in_from_Interrupt
				);
	
	with Reg_mux select --register input MUX
		Reg_Data_in <= 	"00000000" when "00",
								ALU_out when "01",
								Data_Fetch_MUX when "10",
								Data_bus_MUX when "11",
								"00000000" when others;
						
	with Bus_address_internal(15 downto 8) select --Data bus MUX
		Bus_data_in_internal <= Bus_data_in_from_Interrupt when "00000000",
										Bus_data_in when others;
						
	Bus_data_out <= Bus_data_out_internal;
	Bus_address <= Bus_address_internal;
	
end arch;