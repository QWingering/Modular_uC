-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition"
-- CREATED		"Mon Apr 20 17:52:40 2020"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY Modular_uC IS 
	PORT
	(
		Clk :  IN  STD_LOGIC;
		Reset_n :  IN  STD_LOGIC;
		Bus_data :  INOUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		Interrupt_input :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		Bus_address :  OUT  STD_LOGIC_VECTOR(16 DOWNTO 0)
	);
END Modular_uC;

ARCHITECTURE bdf_type OF Modular_uC IS 

COMPONENT core
GENERIC (INSTR_ROM_SIZE : INTEGER
			);
	PORT(Clk : IN STD_LOGIC;
		 Reset_n : IN STD_LOGIC;
		 Bus_data : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 Instr_data : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 Interrupt_input : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 Bus_address : OUT STD_LOGIC_VECTOR(16 DOWNTO 0);
		 Instr_address : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT instruction_rom
GENERIC (INSTR_SIZE : INTEGER;
			ROM_SIZE : INTEGER
			);
	PORT(CLK : IN STD_LOGIC;
		 Reset_n : IN STD_LOGIC;
		 address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 Data_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(15 DOWNTO 0);


BEGIN 



b2v_inst : core
GENERIC MAP(INSTR_ROM_SIZE => 16
			)
PORT MAP(Clk => Clk,
		 Reset_n => Reset_n,
		 Bus_data => Bus_data,
		 Instr_data => SYNTHESIZED_WIRE_0,
		 Interrupt_input => Interrupt_input,
		 Bus_address => Bus_address,
		 Instr_address => SYNTHESIZED_WIRE_1);


b2v_inst2 : instruction_rom
GENERIC MAP(INSTR_SIZE => 24,
			ROM_SIZE => 16
			)
PORT MAP(CLK => Clk,
		 Reset_n => Reset_n,
		 address => SYNTHESIZED_WIRE_1,
		 Data_out => SYNTHESIZED_WIRE_0);


END bdf_type;