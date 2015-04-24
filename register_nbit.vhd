LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY register_nbit IS
	GENERIC(N: INTEGER :=8);
	PORT (R : IN STD_LOGIC_VECTOR((N-1) DOWNTO 0);
	Clk, Rstn : IN STD_LOGIC;
	Q : OUT STD_LOGIC_VECTOR((N-1) DOWNTO 0));
END register_nbit;

ARCHITECTURE Behavior OF register_nbit IS
BEGIN
	PROCESS (Clk, Rstn)
	BEGIN
		IF (Rstn = '0') THEN
			Q <= (OTHERS => '0');
		ELSIF (Clk'EVENT AND Clk = '1') THEN
			Q <= R;
		END IF;
	END PROCESS;
END Behavior; 