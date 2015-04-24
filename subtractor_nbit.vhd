LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_misc.all;

ENTITY subtractor_nbit IS
GENERIC(N: INTEGER := 10);
PORT ( A, B : IN STD_LOGIC_VECTOR((N-1) DOWNTO 0);
	DIFF: BUFFER STD_LOGIC_VECTOR((N-1) DOWNTO 0);
	OVERFLOW, UNDERFLOW, OV255, OV127, UN_256, UN_128: OUT STD_LOGIC);
END subtractor_nbit;

ARCHITECTURE Structural OF subtractor_nbit IS

COMPONENT single_full_adder
	PORT (A, B, CI: IN STD_LOGIC;
		S, CO: OUT STD_LOGIC);
END COMPONENT;

SIGNAL CARRY: STD_LOGIC_VECTOR(N DOWNTO 0);
SIGNAL OV, B_N: STD_LOGIC;

BEGIN

CARRY(0)<='1';

fulladd_gen: FOR I IN 0 TO (N-1) GENERATE
  B_N <= NOT B(I);
	FF: single_full_adder PORT MAP (A(I), B_N, CARRY(I), DIFF(I), CARRY(I+1));	
END GENERATE;

OV<=CARRY(N) XOR CARRY(N-1);
OVERFLOW<= (NOT A(N-1)) AND OV;
UNDERFLOW<= A(N-1) AND OV;
OV255<= or_reduce(DIFF((N-1) DOWNTO 8));
OV127<= or_reduce(DIFF((N-1) DOWNTO 7));
UN_256<= nand_reduce(DIFF((N-1) DOWNTO 8));
UN_128<= nand_reduce(DIFF((N-1) DOWNTO 7));

END Structural; 