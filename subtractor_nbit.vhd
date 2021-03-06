LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_misc.all;

ENTITY subtractor_nbit IS
GENERIC(N: INTEGER := 10);
PORT ( A, B : IN STD_LOGIC_VECTOR((N-1) DOWNTO 0);
	DIFF: BUFFER STD_LOGIC_VECTOR((N-1) DOWNTO 0);
	OVERFLOW, UNDERFLOW: OUT STD_LOGIC);
END subtractor_nbit;

ARCHITECTURE Structural OF subtractor_nbit IS

COMPONENT single_full_adder
	PORT (A, B, CI: IN STD_LOGIC;
		S, CO: OUT STD_LOGIC);
END COMPONENT;

SIGNAL CARRY: STD_LOGIC_VECTOR(N DOWNTO 0);
SIGNAL B_N: STD_LOGIC_VECTOR((N-1) DOWNTO 0);
SIGNAL OV: STD_LOGIC;

BEGIN

B_N<= NOT B;
CARRY(0)<='1';

fulladd_gen: FOR I IN 0 TO (N-1) GENERATE
	FF: single_full_adder PORT MAP (A(I), B_N(I), CARRY(I), DIFF(I), CARRY(I+1));	
END GENERATE;

OV<=CARRY(N) XOR CARRY(N-1);
OVERFLOW<= (NOT A(N-1)) AND OV;
UNDERFLOW<= A(N-1) AND OV;

END Structural; 