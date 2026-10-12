LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY moduloTeclado IS
	PORT (
		clock : IN std_logic; -- Reloj del teclado
		data : IN std_logic; -- Bits del teclado
		clock_50Mhz : IN std_logic; -- Reloj de la tarjeta
		reset : IN std_logic; -- Reinicio
		read1 : IN std_logic; -- Aviso del decodificador, indica que ya leyo la tecla y puede borrar alerta
		scan_code : OUT std_logic_vector(7 downto 0); -- Vector de 8 bits que contiene el codigo de la tecla presionada
		scan_ready : OUT std_logic -- Pulso de 1 bit que se pone en 1 cuando detecta que se debe leer una tecla que acaba de ser presionada
	);
END moduloTeclado;


ARCHITECTURE basic OF moduloTeclado IS
	SIGNAL incnt                   : std_logic_vector(3 downto 0) := "0000"; -- Contador de 0 a 10, ya que el protocolo PS/2 envia 11 bits por cada tecla
	SIGNAL shiftin                 : std_logic_vector(8 downto 0) := "000000000"; -- Registro de desplazamiento
	SIGNAL read_char               : std_logic := '0'; -- Bandera logica que indica si el modulo esta leyendo
	SIGNAL clock_enable            : std_logic := '0'; -- Bandera logica que indica si el modulo esta puede leer
	SIGNAL ready_set               : std_logic := '0'; -- Bandera logica que indica si el modulo termino de leer
	SIGNAL keyboard_clk_filtered   : std_logic := '0'; -- Bandera que indica cuando filter se llena de unos o ceros, indica cambio de nivel estable
	SIGNAL filter                  : std_logic_vector(7 downto 0); -- Guarda ultimas 8 lecturas del pin clock
BEGIN 
	PROCESS (read1, ready_set)
	BEGIN
		IF read1 = '1' THEN
			scan_ready <= '0';
		ELSIF ready_set'event and ready_set = '1'THEN
			scan_ready <= '1';
		END IF;
	END PROCESS;
	
	
	clock_filter: PROCESS
	BEGIN
		WAIT UNTIL clock_50Mhz'event and clock_50Mhz = '1';
		clock_enable <= not clock_enable;
		IF clock_enable = '1'THEN
			filter(6 downto 0) <= filter(7 downto 1);
			filter(7) <= clock;
			IF filter = "11111111" THEN
				keyboard_clk_filtered <= '1';
			ELSIF filter = "00000000" THEN
				keyboard_clk_filtered <= '0';
			END IF;
		END IF;
	END PROCESS clock_filter;
	
	
	PROCESS
	BEGIN
		WAIT UNTIL (keyboard_clk_filtered'event and keyboard_clk_filtered = '1');
		IF reset = '0'THEN
			incnt <= "0000";
			read_char <= '0';
		ELSE
			IF data = '0'AND read_char = '0' THEN
				read_char <= '1';
				ready_set <= '0';
			ELSE
				IF read_char = '1' THEN
					IF incnt < "1001" THEN
						incnt <= incnt + 1;
						shiftin(7 downto 0) <= shiftin(8 downto 1);
						shiftin(8) <= data;
						ready_set <= '0';
					ELSE
						scan_code <= shiftin(7 downto 0);
						read_char <= '0';
						ready_set <= '1';
						incnt <= "0000";
					END IF;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END basic;
						