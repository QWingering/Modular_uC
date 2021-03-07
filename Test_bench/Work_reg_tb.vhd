library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Work_reg_tb is
end entity;


architecture bhv of Work_reg_tb is

	component Work_reg is 
		port(
			Reg_Data_out : out std_logic_vector(7 downto 0);		--sortie de donnée du module
			Reg_Data_out_A : out std_logic_vector(7 downto 0);		--sortie vers entrée A de l'ALU
			Reg_Data_out_B : out std_logic_vector(7 downto 0);		--sortie vers entrée B de l'ALU
			Reg_Data_in : in std_logic_vector(7 downto 0);			--entrée de données 
			Reg_Control : in std_logic_vector(16 downto 0);			--controle des MUX
			
			CLK : in std_logic;
			Reset_n : in std_logic
		);
	end component;
	
	signal Reg_Data_out_tb : std_logic_vector(7 downto 0);
	signal Reg_Data_out_A_tb : std_logic_vector(7 downto 0);
	signal Reg_Data_out_B_tb : std_logic_vector(7 downto 0);
	signal Reg_Data_in_tb : std_logic_vector(7 downto 0) := "00011000";
	signal Reg_Control_tb : std_logic_vector(12 downto 0);	
	
	signal CLK_tb : std_logic := '0';
	signal Reset_n_tb : std_logic :='1';
	
begin

	DUT1 : entity work.Work_reg(arch)
		port map (	Reg_Data_out => Reg_Data_out_tb,
						Reg_Data_out_A => Reg_Data_out_A_tb, 
						Reg_Data_out_B => Reg_Data_out_B_tb, 
						Reg_Data_in => Reg_Data_in_tb,
						Reg_Control => Reg_Control_tb,
						CLK => CLK_tb,
						Reset_n => Reset_n_tb);
						
	process
		begin
			wait for 0.5 ns;
			CLK_tb <= not(CLK_tb);
		end process;
		
	process
		begin
			wait for 5 ns;
			Reg_Data_in_tb <= "00111100";
			Reg_control_tb <= "00001001000001001";
		end process;

end bhv;