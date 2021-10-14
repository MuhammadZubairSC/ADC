-- Copyright (C) 2016  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Intel and sold by Intel or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 16.1.0 Build 196 10/24/2016 SJ Lite Edition"
-- CREATED		"Fri Oct 15 00:35:29 2021"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY pwm_led_top IS 
	PORT
	(
		MAX10_CLK1_50 :  IN  STD_LOGIC;
		ADC_CLK_10 :  IN  STD_LOGIC;
		ARDUINO_RESET_N :  IN  STD_LOGIC;
		SW :  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		ARDUINO_IO :  OUT  STD_LOGIC_VECTOR(0 TO 0);
		HEX0 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX1 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX2 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX3 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX4 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		HEX5 :  OUT  STD_LOGIC_VECTOR(6 DOWNTO 0);
		LEDR :  OUT  STD_LOGIC_VECTOR(0 TO 0)
	);
END pwm_led_top;

ARCHITECTURE bdf_type OF pwm_led_top IS 

COMPONENT pwm_pll
	PORT(inclk0 : IN STD_LOGIC;
		 c0 : OUT STD_LOGIC;
		 c1 : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT adc
	PORT(clk_clk : IN STD_LOGIC;
		 reset_reset_n : IN STD_LOGIC;
		 mm_bridge_0_s0_burstcount : IN STD_LOGIC;
		 mm_bridge_0_s0_write : IN STD_LOGIC;
		 mm_bridge_0_s0_read : IN STD_LOGIC;
		 mm_bridge_0_s0_debugaccess : IN STD_LOGIC;
		 mm_bridge_0_s0_address : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 mm_bridge_0_s0_byteenable : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 mm_bridge_0_s0_writedata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 modular_adc_0_response_valid : OUT STD_LOGIC;
		 modular_adc_0_response_startofpacket : OUT STD_LOGIC;
		 modular_adc_0_response_endofpacket : OUT STD_LOGIC;
		 modular_adc_0_response_empty : OUT STD_LOGIC;
		 mm_bridge_0_s0_waitrequest : OUT STD_LOGIC;
		 mm_bridge_0_s0_readdatavalid : OUT STD_LOGIC;
		 mm_bridge_0_s0_readdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 modular_adc_0_response_channel : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		 modular_adc_0_response_data : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
END COMPONENT;

COMPONENT debouncer
	PORT(noisy : IN STD_LOGIC;
		 clk : IN STD_LOGIC;
		 debounced : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT pwm_gen
	PORT(clk : IN STD_LOGIC;
		 duty_cycle : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 pwm : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT adc_connect
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 mm_bridge_0_s0_waitrequest : IN STD_LOGIC;
		 mm_bridge_0_s0_readdatavalid : IN STD_LOGIC;
		 modular_adc_0_valid : IN STD_LOGIC;
		 modular_adc_0_response_empty : IN STD_LOGIC;
		 modular_adc_0_startofpacket : IN STD_LOGIC;
		 modular_adc_0_endofpacket : IN STD_LOGIC;
		 mm_bridge_0_s0_readdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 modular_adc_0_channel : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 modular_adc_0_data : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 mm_bridge_0_s0_burstcount : OUT STD_LOGIC;
		 mm_bridge_0_s0_write : OUT STD_LOGIC;
		 mm_bridge_0_s0_read : OUT STD_LOGIC;
		 mm_bridge_0_s0_debugaccess : OUT STD_LOGIC;
		 led7 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		 mm_bridge_0_s0_address : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		 mm_bridge_0_s0_byteenable : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 mm_bridge_0_s0_writedata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT seg7_lut_6
	PORT(iDIG : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 oSEG0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 oSEG1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 oSEG2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 oSEG3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 oSEG4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 oSEG5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	duty_cycle :  STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL	duty_cycle_clk :  STD_LOGIC;
SIGNAL	pwm :  STD_LOGIC;
SIGNAL	pwm_clk :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_12 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_13 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_14 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_15 :  STD_LOGIC_VECTOR(11 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_16 :  STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_17 :  STD_LOGIC;


BEGIN 
ARDUINO_IO(0) <= SYNTHESIZED_WIRE_17;
LEDR(0) <= SYNTHESIZED_WIRE_17;



b2v_inst : pwm_pll
PORT MAP(inclk0 => MAX10_CLK1_50,
		 c0 => pwm_clk,
		 c1 => duty_cycle_clk);


b2v_inst1 : adc
PORT MAP(clk_clk => ADC_CLK_10,
		 reset_reset_n => ARDUINO_RESET_N,
		 mm_bridge_0_s0_burstcount => SYNTHESIZED_WIRE_0,
		 mm_bridge_0_s0_write => SYNTHESIZED_WIRE_1,
		 mm_bridge_0_s0_read => SYNTHESIZED_WIRE_2,
		 mm_bridge_0_s0_debugaccess => SYNTHESIZED_WIRE_3,
		 mm_bridge_0_s0_address => SYNTHESIZED_WIRE_4,
		 mm_bridge_0_s0_byteenable => SYNTHESIZED_WIRE_5,
		 mm_bridge_0_s0_writedata => SYNTHESIZED_WIRE_6,
		 modular_adc_0_response_valid => SYNTHESIZED_WIRE_9,
		 modular_adc_0_response_startofpacket => SYNTHESIZED_WIRE_11,
		 modular_adc_0_response_endofpacket => SYNTHESIZED_WIRE_12,
		 modular_adc_0_response_empty => SYNTHESIZED_WIRE_10,
		 mm_bridge_0_s0_waitrequest => SYNTHESIZED_WIRE_7,
		 mm_bridge_0_s0_readdatavalid => SYNTHESIZED_WIRE_8,
		 mm_bridge_0_s0_readdata => SYNTHESIZED_WIRE_13,
		 modular_adc_0_response_channel => SYNTHESIZED_WIRE_14,
		 modular_adc_0_response_data => SYNTHESIZED_WIRE_15);


SYNTHESIZED_WIRE_17 <= NOT(pwm);



b2v_inst3 : debouncer
PORT MAP(noisy => SW(0),
		 clk => duty_cycle_clk,
		 debounced => duty_cycle(0));


b2v_inst4 : debouncer
PORT MAP(noisy => SW(1),
		 clk => duty_cycle_clk,
		 debounced => duty_cycle(1));


b2v_inst5 : debouncer
PORT MAP(noisy => SW(2),
		 clk => duty_cycle_clk,
		 debounced => duty_cycle(2));


b2v_inst6 : pwm_gen
PORT MAP(clk => pwm_clk,
		 duty_cycle => duty_cycle,
		 pwm => pwm);


b2v_inst7 : adc_connect
PORT MAP(clk => ADC_CLK_10,
		 reset_n => ARDUINO_RESET_N,
		 mm_bridge_0_s0_waitrequest => SYNTHESIZED_WIRE_7,
		 mm_bridge_0_s0_readdatavalid => SYNTHESIZED_WIRE_8,
		 modular_adc_0_valid => SYNTHESIZED_WIRE_9,
		 modular_adc_0_response_empty => SYNTHESIZED_WIRE_10,
		 modular_adc_0_startofpacket => SYNTHESIZED_WIRE_11,
		 modular_adc_0_endofpacket => SYNTHESIZED_WIRE_12,
		 mm_bridge_0_s0_readdata => SYNTHESIZED_WIRE_13,
		 modular_adc_0_channel => SYNTHESIZED_WIRE_14,
		 modular_adc_0_data => SYNTHESIZED_WIRE_15,
		 mm_bridge_0_s0_burstcount => SYNTHESIZED_WIRE_0,
		 mm_bridge_0_s0_write => SYNTHESIZED_WIRE_1,
		 mm_bridge_0_s0_read => SYNTHESIZED_WIRE_2,
		 mm_bridge_0_s0_debugaccess => SYNTHESIZED_WIRE_3,
		 led7 => SYNTHESIZED_WIRE_16,
		 mm_bridge_0_s0_address => SYNTHESIZED_WIRE_4,
		 mm_bridge_0_s0_byteenable => SYNTHESIZED_WIRE_5,
		 mm_bridge_0_s0_writedata => SYNTHESIZED_WIRE_6);


b2v_inst8 : seg7_lut_6
PORT MAP(iDIG => SYNTHESIZED_WIRE_16,
		 oSEG0 => HEX0,
		 oSEG1 => HEX1,
		 oSEG2 => HEX2,
		 oSEG3 => HEX3,
		 oSEG4 => HEX4,
		 oSEG5 => HEX5);


END bdf_type;