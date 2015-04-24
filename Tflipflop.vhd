LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Tflipflop IS
PORT ( Clk, Rstn, T : IN STD_LOGIC;
	Q : BUFFER STD_LOGIC);
END Tflipflop;

ARCHITECTURE Structural OF Tflipflop IS
BEGIN
	PROCESS (Clk, Rstn)
	BEGIN
		IF (Rstn='0') THEN
			Q<='0';
		ELSIF (Clk='1' AND Clk'EVENT) THEN
			IF(T='1') THEN
				IF(Q='0') THEN
					Q<='1';
				ELSE
					Q<='0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Structural; 