LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY single_full_adder IS
	PORT (A, B, CI: IN STD_LOGIC;
		S, CO: OUT STD_LOGIC);
END single_full_adder;

ARCHITECTURE add OF single_full_adder IS
SIGNAL G: STD_LOGIC;
BEGIN
	G <= A XOR B;
	S <= G XOR CI;
	CO <= CI WHEN G='1' ELSE
		B;
END add; 