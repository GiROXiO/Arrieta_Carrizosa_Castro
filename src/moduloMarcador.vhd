LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY moduloMarcador IS
    PORT (
        clk_50mhz : IN std_logic;
        reset     : IN std_logic;
        
        -- Pulsos de gol provenientes del moduloLogica
        score_p1  : IN std_logic;
        score_p2  : IN std_logic;
        
        -- Salidas a los displays de 7 segmentos (7 bits cada uno)
        hex_p1    : OUT std_logic_vector(6 DOWNTO 0);
        hex_p2    : OUT std_logic_vector(6 DOWNTO 0)
    );
END moduloMarcador;

ARCHITECTURE behavioral OF moduloMarcador IS

    -- Registros internos para llevar la cuenta (de 0 a 9)
    SIGNAL count_p1 : integer RANGE 0 TO 9 := 0;
    SIGNAL count_p2 : integer RANGE 0 TO 9 := 0;

    -- Función pura para traducir un número decimal al código de 7 segmentos
    FUNCTION decodificador_7seg(num : integer) RETURN std_logic_vector IS
        VARIABLE segmentos : std_logic_vector(6 DOWNTO 0);
    BEGIN
        CASE num IS
            WHEN 0 => segmentos := "1000000"; 
            WHEN 1 => segmentos := "1111001"; 
            WHEN 2 => segmentos := "0100100";
            WHEN 3 => segmentos := "0110000";
            WHEN 4 => segmentos := "0011001";
            WHEN 5 => segmentos := "0010010";
            WHEN 6 => segmentos := "0000010";
            WHEN 7 => segmentos := "1111000";
            WHEN 8 => segmentos := "0000000"; 
            WHEN 9 => segmentos := "0010000";
            WHEN OTHERS => segmentos := "1111111";
        END CASE;
        RETURN segmentos;
    END FUNCTION;

BEGIN

    -- Proceso para actualizar los contadores
    PROCESS(clk_50mhz, reset)
    BEGIN
        IF reset = '0' THEN
            count_p1 <= 0;
            count_p2 <= 0;
        ELSIF rising_edge(clk_50mhz) THEN
            
            -- Si detecta el pulso de gol del Jugador 1
            IF score_p1 = '1' THEN
                IF count_p1 = 9 THEN
                    count_p1 <= 0; -- Reinicia a 0 si llega a 9
                ELSE
                    count_p1 <= count_p1 + 1;
                END IF;
            END IF;

            -- Si detecta el pulso de gol del Jugador 2
            IF score_p2 = '1' THEN
                IF count_p2 = 9 THEN
                    count_p2 <= 0;
                ELSE
                    count_p2 <= count_p2 + 1;
                END IF;
            END IF;
            
        END IF;
    END PROCESS;

    -- Conectar los contadores a la función de decodificación continuamente
    hex_p1 <= decodificador_7seg(count_p1);
    hex_p2 <= decodificador_7seg(count_p2);

END behavioral;