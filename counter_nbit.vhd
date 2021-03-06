LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY counter_nbit IS
GENERIC(N: INTEGER := 10);
PORT ( Clk, Clrn, E : IN STD_LOGIC;
	COUNT : BUFFER STD_LOGIC_VECTOR((N-1) DOWNTO 0);
	MAX_VAL: OUT STD_LOGIC);
END counter_nbit;

ARCHITECTURE Structural OF counter_nbit IS

COMPONENT Tflipflop
PORT ( Clk, Rstn, T : IN STD_LOGIC;
	Q : BUFFER STD_LOGIC);
END COMPONENT;

SIGNAL FFIN: STD_LOGIC_VECTOR(N DOWNTO 0);

BEGIN

FFIN(0)<=E;
FFIN(N DOWNTO 1)<= COUNT((N-1) DOWNTO 0) AND FFIN((N-1) DOWNTO 0);
MAX_VAL<=FFIN(N);

count_gen: FOR I IN 0 TO (N-1) GENERATE
	FF: Tflipflop PORT MAP (Clk, Clrn, FFIN(I), COUNT(I));	
END GENERATE;
END Structural; 