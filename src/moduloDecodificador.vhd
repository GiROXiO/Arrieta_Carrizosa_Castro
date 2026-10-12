LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY moduloDecodificador IS
    PORT (
        clk        : IN  std_logic;                     -- Reloj del sistema (50 MHz)
        rst        : IN  std_logic;                     -- Reset asíncrono
        scan_code  : IN  std_logic_vector(7 downto 0);  -- Código proveniente de moduloTeclado
        scan_ready : IN  std_logic;                     -- Bandera de dato listo de moduloTeclado
        read_ack   : OUT std_logic;                     -- Pulso de confirmación hacia read1 de moduloTeclado
        p1_up      : OUT std_logic;                     -- Estado mantenido tecla W
        p1_down    : OUT std_logic;                     -- Estado mantenido tecla S
        p2_up      : OUT std_logic;                     -- Estado mantenido flecha arriba
        p2_down    : OUT std_logic                      -- Estado mantenido flecha abajo
    );
END moduloDecodificador;


ARCHITECTURE Behavioral of moduloDecodificador IS
    SIGNAL is_break : std_logic := '0'; -- Bandera que recuerda si el byte anterior fue F0
BEGIN
    PROCESS(clk, rst)
    BEGIN
        IF rst = '0' THEN
            p1_up    <= '0';
            p1_down  <= '0';
            p2_up    <= '0';
            p2_down  <= '0';
            is_break <= '0';
            read_ack <= '0';
        ELSIF rising_edge(clk) then
            read_ack <= '0'; -- Por defecto no confirma lectura salvo cuando llega dato
            IF scan_ready = '1' then
                read_ack <= '1'; -- Avisa a moduloTeclado que ya leyó               
                IF scan_code = x"F0" then
                    is_break <= '1'; -- El siguiente scan_code corresponderá a una tecla soltada
                ELSE
                    IF is_break = '1' THEN
                        -- Soltaron una tecla: desactivar la acción correspondiente
                        CASE scan_code IS
                            WHEN x"1D" => p1_up   <= '0'; -- Soltó W
                            WHEN x"1B" => p1_down <= '0'; -- Soltó S
                            WHEN x"75" => p2_up   <= '0'; -- Soltó Flecha Arriba
                            WHEN x"72" => p2_down <= '0'; -- Soltó Flecha Abajo
                            WHEN OTHERS => NULL;
                        END CASE;
                        is_break <= '0'; -- Resetea la bandera de ruptura
                    ELSE
                        -- Presionaron una tecla: activar la acción correspondiente
                        CASE scan_code IS
                            WHEN x"1D" => p1_up   <= '1'; -- Presionó W
                            WHEN x"1B" => p1_down <= '1'; -- Presionó S
                            WHEN x"75" => p2_up   <= '1'; -- Presionó Flecha Arriba
                            WHEN x"72" => p2_down <= '1'; -- Presionó Flecha Abajo
                            WHEN OTHERS => NULL;
                        END CASE;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;
END Behavioral;