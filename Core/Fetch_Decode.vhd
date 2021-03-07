library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fetch_Decode is
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
		Reg_Control : out std_logic_vector(16 downto 0)   -- Control signals for the registers
	);
end entity;


architecture arch of Fetch_Decode is

	signal PC : std_logic_vector((INSTR_ROM_SIZE-1) downto 0) := (others => '0'); --first instruction to read is at 0, should be a GOTO, instruction @1 is interrupt handling
	
begin
	
	instr_add <= PC;
	
	process(Clk, Reset_n)
		variable instr_state : integer range 0 to 3;
		variable Instruction : std_logic_vector(23 downto 0) := (others =>'0'); --first instruction should be NOP
		variable Jump_since_interrupt : integer range 0 to 15 := 0; --if different from 0 means the code is executing an interrupt
		
		begin
			if(Reset_n = '0') then --reset state
				instr_state := 0;
				PC <= (others => '0');
				instruction := (others => '0');
				Bus_address <= (others => '0');
				Alu_op_code <= (others => '0');
				Jump_since_interrupt := 0;
			elsif falling_edge(Clk) then
				
				--set default values that can be overwritten later in the process
				Stack_read_element <= '0';
				Stack_add_element <= '0';
				Reg_input_mux 	<= (others => '0');
				Reg_Control 	<= (others => '0');
				Data_out <= (others => '0');
				Bus_address <= (others => '0');
				Alu_op_code <= (others => '0');
				Stack_add_out <= (others => '0');
				
				if(instr_state = 0) then --at the begining we store the instruction
					if(Jump_since_interrupt = 0 and Int_interrupt_in = '1')then --if we are not in an interruption but the request flag is on... new instruction is the interuption handling
						Instruction := "111100000000000000000000"; --interruption
						Jump_since_interrupt := 1;
					else
						Instruction := instr_Data; --stores the current instruction
					end if;
				end if;
				
				case Instruction(23 downto 20) is 
					when "0000" => --No OPeration (NOP)
						if(instr_state = 3)then
							PC <= std_logic_vector(unsigned(PC) + 1); --next instruction
						end if;
						
					when "0001" => --GO TO given instruction address (GOTO)
						if(instr_state = 3)then
							PC <= instruction(15 downto 0);
						end if;
						
					when "0010" => --go to given instruction address and store current address to stack (CALL)
						if(instr_state = 2) then
							Stack_add_out <= std_logic_vector(unsigned(PC) + 1);
							Stack_add_element <= '1';
						elsif (instr_state = 3) then
							PC <= instruction(15 downto 0);
							if(Jump_since_interrupt /= 0) then
								Jump_since_interrupt := Jump_since_interrupt + 1;
							end if;
						end if;
						
					when "0011" => --return to the address stored at the top of the stack (RETURN)
						if(instr_state = 2) then
							Stack_read_element <= '1';
						elsif (instr_state = 3) then
							PC <= Stack_add_in;
							if(Jump_since_interrupt /= 0) then --only used in interruptions to decrease interrupt counter 
								Jump_since_interrupt := Jump_since_interrupt - 1;
							end if;
						end if;
						
					when "0100" => --Exectute operation (...)
						if(instr_state = 0) then
							Reg_input_mux <= "01";
							Reg_Control <= "0" & instruction(19 downto 8) & "0000";
							Alu_op_code <= instruction(3 downto 0);
						elsif(instr_state = 1) then
							Reg_input_mux <= "01";
							Reg_Control <= "1" & instruction(19 downto 8) & "0000";
							Alu_op_code <= instruction(3 downto 0);
						elsif(instr_state = 3) then
							PC <= std_logic_vector(unsigned(PC) + 1); --next instruction
						end if;
						
					when "0101" => --Move data from Module to work registers (MOVMW)
						if(instr_state = 0) then
							Bus_address <= "1" & instruction(15 downto 0);
						elsif(instr_state = 2) then
							Reg_input_mux <= "11";
							Reg_Control <= "1" & instruction(19 downto 16) & "000000000000";
						elsif(instr_state = 3) then
							PC <= std_logic_vector(unsigned(PC) + 1); --next instruction
						end if;
						
					when "0110" => --Move data from work to modules (MOVWM)
						if(instr_state = 0) then
							Reg_Control <= "0000000000000" & instruction(19 downto 16);
						elsif(instr_state = 1) then
							Reg_Control <= "0000000000000" & instruction(19 downto 16);
							Bus_address <= "0" & instruction(15 downto 0);
						elsif(instr_state = 3) then
							PC <= std_logic_vector(unsigned(PC) + 1); --next instruction
						end if;
						
					when "0111" => --Load litteral to work (LLW)
						if(instr_state = 0) then
							Data_out <= instruction(7 downto 0);
							Reg_input_mux <= "10";
							Reg_Control <= "1" & instruction(19 downto 16) & "000000000000";
						elsif(instr_state = 3) then 
							PC <= std_logic_vector(unsigned(PC) + 1);
						end if;
						
					when "1000" => --execute Operation, skip if zero (...)
						if(instr_state = 0) then
							Reg_input_mux <= "01";
							Reg_Control <= "0" & instruction(19 downto 8) & "0000";
							Alu_op_code <= instruction(3 downto 0);
						elsif(instr_state = 1) then
							Reg_input_mux <= "01";
							Alu_op_code <= instruction(3 downto 0);
							if(instruction(7 downto 4 )= "1111") then
								Reg_Control <= "1" & instruction(19 downto 8) & "0000";
							else
								Reg_Control <= "0" & instruction(19 downto 8) & "0000";
							end if;
							
							if(Alu_Test_Zero = '1') then
								PC <= std_logic_vector(unsigned(PC) + 2); --skip the next instruction 
							else 
								PC <= std_logic_vector(unsigned(PC) + 1); --next instruction
							end if;	
						end if;
					
					when "1111" => --interrupt request (similar to a CALL with different address)
						if(instr_state = 2) then
							Stack_add_out <= std_logic_vector(unsigned(PC));
							Stack_add_element <= '1';
						elsif (instr_state = 3) then
							PC <= "0000000000000001";
						end if;
					when others => --unknown code
				end case;
				
				if(instr_state = 3) then --test for end of current instruction
					instr_state := 0;
				else
					instr_state := instr_state+1;
				end if;
			end if;
		end process;
	
end arch;