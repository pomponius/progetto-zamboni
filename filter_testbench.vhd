LIBRARY ieee;
LIBRARY std;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE std.textio.all;

ENTITY filter_testbench IS

END;

ARCHITECTURE Behaviour OF filter_testbench IS
	TYPE Ram IS ARRAY(1023 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
		
	CONSTANT CLK_period : TIME := 1 ms;
	CONSTANT delay_short : TIME := 1 ns;
	CONSTANT delay_long : TIME := 1 ms;
	CONSTANT seed : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001011"; --:= "10010011";
	
	SIGNAL CLK, RSTN, START, RD_DATA_OUT, DONE : STD_LOGIC;
	SIGNAL DATA_IN, DATA_OUT : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ADDRESS_DATA_OUT : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL RAM1, RAM2 : Ram;

	COMPONENT filter IS
		PORT (CLK, RSTN, START, RD_DATA_OUT : IN STD_LOGIC;
			DATA_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			ADDRESS_DATA_OUT : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			DATA_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			DONE: OUT STD_LOGIC);
  	END COMPONENT;
	
	BEGIN
	   dut : filter PORT MAP (CLK, RSTN, START, RD_DATA_OUT, DATA_IN, ADDRESS_DATA_OUT, DATA_OUT, DONE);
	    
		clock_gen : PROCESS
			BEGIN
			  CLK <= '0';
				WAIT FOR CLK_period/2;
				CLK <= '1';
				WAIT FOR CLK_period/2;
		END PROCESS;
		
		run : PROCESS
		  FILE outfile : TEXT IS OUT "outfile.txt";
		  VARIABLE buf : LINE;
		  VARIABLE a, b, c, d, shift_a, shift_b, errors, temp_hits, result : INTEGER := 0;
		  VARIABLE average : REAL;
			VARIABLE rand_temp : STD_LOGIC_VECTOR(7 DOWNTO 0):= seed;
			VARIABLE temp : STD_LOGIC := '0';
			VARIABLE temp_div: SIGNED(7 DOWNTO 0);
			
			BEGIN
				START <= '0';
				RSTN <= '1';
				RD_DATA_OUT <= '0';
				
				errors := 0;
				temp_hits := 0;
				
				WAIT FOR delay_long;
				
				RSTN <= '0';
				WAIT FOR delay_short;
				RSTN <= '1';
				
				WAIT FOR delay_long;
				
				START <= '1';
				
				WAIT FOR delay_long;
				
				FOR i IN 0 TO 1023 LOOP
					temp := rand_temp(rand_temp'LENGTH-1) XOR rand_temp(rand_temp'LENGTH-2);
					rand_temp(rand_temp'LENGTH-1 DOWNTO 1) := rand_temp(rand_temp'LENGTH-2 DOWNTO 0);
					rand_temp(0) := temp;
					
					RAM1(i) <= rand_temp;
					DATA_IN <= rand_temp;
					
					WAIT FOR delay_long;	
				END LOOP;		
				
				WHILE DONE='0' LOOP
				    WAIT UNTIL CLK='1';
		        temp_hits := temp_hits + 1;  
		    END LOOP;
				
				START<='0';
				RD_DATA_OUT <= '1';
				
				FOR i IN 0 TO 1023 LOOP
				  ADDRESS_DATA_OUT  <= STD_LOGIC_VECTOR(TO_UNSIGNED(i, ADDRESS_DATA_OUT'LENGTH));
				  WAIT FOR delay_long;
				  RAM2(i) <= DATA_OUT;
				  WAIT FOR delay_long;
				END LOOP;
				
				FOR i IN 0 TO 1023 LOOP
				  IF i>1 THEN
				    b:=TO_INTEGER(SIGNED(RAM2(i-2)));
				  ELSE
				    b:=0;
				  END IF;
				  
				  IF i>0 THEN
				    a:=TO_INTEGER(SIGNED(RAM2(i-1)));
				    d:=TO_INTEGER(SIGNED(RAM1(i-1)));
				  ELSE
				    a:=0;
				    d:=0;
				  END IF;
				  
				  c:=TO_INTEGER(SIGNED(RAM1(i)));
				  
				  temp_div:=to_signed(a, 8);
				  shift_a:=to_integer(temp_div(7)&temp_div(7 downto 1));
				  temp_div:=to_signed(b, 8);
				  shift_b:=to_integer(temp_div(7)&temp_div(7)&temp_div(7 downto 2));
				  
				  result:=shift_a-shift_b-4*c+2*d;
				  IF result>127 THEN
				    result:=127;
				  ELSIF result<-128 THEN
				    result:=-128;
				  END IF;
				  
				  IF result/=TO_INTEGER(SIGNED(RAM2(i))) THEN
				    write(buf, STRING'("ERROR: cell "));
				    write(buf, i);
				    write(buf, STRING'(" is "));
				    write(buf, TO_INTEGER(SIGNED(RAM2(i))));
				    write(buf, STRING'(", should be "));
				    write(buf, result);
				    WRITELINE (outfile, buf);
				    errors := errors + 1;
				  END IF;			  
				END LOOP;
				
				write(buf, STRING'("TOTAL ERRORS: "));
			  write(buf, errors);
			  WRITELINE (outfile, buf);
			  write(buf, STRING'("The algorithm took "));
			  write(buf, temp_hits);
			  write(buf, STRING'(" clock hits to be completed, with an average of "));
			  average := REAL(temp_hits)/1024.0;
			  write(buf, average);
			  write(buf, STRING'(" operations per memory cell."));
			  WRITELINE (outfile, buf);
			  
			  WAIT FOR delay_long*20;				
		END PROCESS;		
END;
