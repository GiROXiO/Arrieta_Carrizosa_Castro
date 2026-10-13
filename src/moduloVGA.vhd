LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY moduloVGA IS
    PORT (
        clk_50mhz : IN std_logic; -- Reloj base de la tarjeta (50 mhz)
        reset     : IN std_logic; -- Boton de reinicio
        hsync     : OUT std_logic; -- Sincronismo horizontal para el monitor
        vsync     : OUT std_logic; -- Sincronismo vertical para el monitor
        pixel_x   : OUT std_logic_vector(9 DOWNTO 0); -- Coordenada x del pixel actual
        pixel_y   : OUT std_logic_vector(9 DOWNTO 0); -- Coordenada y del pixel actual
        video_on  : OUT std_logic; -- Indica si estamos dentro del area visible para dibujar
        p_tick    : OUT std_logic  -- Pulso de reloj de 25 mhz para sincronizar el dibujo
    );
END moduloVGA;

ARCHITECTURE behavioral OF moduloVGA IS

    -- Constantes para los tiempos del recorrido horizontal (pixeles)
    CONSTANT hd : integer := 640; -- Area visible de la pantalla (ancho)
    CONSTANT hf : integer := 16;  -- Margen derecho oscuro (front porch)
    CONSTANT hb : integer := 48;  -- Margen izquierdo oscuro (back porch)
    CONSTANT hr : integer := 96;  -- Pulso de sincronismo horizontal
    CONSTANT h_total : integer := hd + hf + hb + hr; -- Total de pixeles por linea (800)

    -- Constantes para los tiempos del recorrido vertical (lineas)
    CONSTANT vd : integer := 480; -- Area visible de la pantalla (alto)
    CONSTANT vf : integer := 10;  -- Margen inferior oscuro (front porch)
    CONSTANT vb : integer := 33;  -- Margen superior oscuro (back porch)
    CONSTANT vr : integer := 2;   -- Pulso de sincronismo vertical
    CONSTANT v_total : integer := vd + vf + vb + vr; -- Total de lineas por cuadro (525)

    -- Señal para dividir el reloj de 50 mhz a 25 mhz
    SIGNAL pixel_tick : std_logic := '0';

    -- Contadores para llevar el seguimiento de en que pixel y fila vamos
    SIGNAL h_count : unsigned(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL v_count : unsigned(9 DOWNTO 0) := (OTHERS => '0');

    -- Señales internas temporales para los sincronismos
    SIGNAL hsync_reg : std_logic := '1';
    SIGNAL vsync_reg : std_logic := '1';

BEGIN

    -- Proceso para dividir el reloj de la fpga a la mitad (25 mhz)
    PROCESS(clk_50mhz, reset)
    BEGIN
        IF reset = '0' THEN
            pixel_tick <= '0';
        ELSIF rising_edge(clk_50mhz) THEN
            pixel_tick <= NOT pixel_tick; -- Cambia de 0 a 1 constantemente
        END IF;
    END PROCESS;

    -- Proceso principal para actualizar los contadores de pantalla
    PROCESS(clk_50mhz, reset)
    BEGIN
        IF reset = '0' THEN
            h_count <= (OTHERS => '0');
            v_count <= (OTHERS => '0');
        ELSIF rising_edge(clk_50mhz) THEN
            IF pixel_tick = '1' THEN -- Solo avanza cuando el reloj de pixeles esta en 1
                IF h_count = (h_total - 1) THEN
                    h_count <= (OTHERS => '0'); -- Se acabo la linea, vuelve al inicio
                    IF v_count = (v_total - 1) THEN
                        v_count <= (OTHERS => '0'); -- Se acabo la pantalla, vuelve arriba
                    ELSE
                        v_count <= v_count + 1; -- Pasa a la siguiente linea hacia abajo
                    END IF;
                ELSE
                    h_count <= h_count + 1; -- Avanza un pixel hacia la derecha
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Generacion de las señales fisicas de sincronismo (se apagan durante su respectivo margen)
    hsync_reg <= '0' WHEN (h_count >= (hd + hf)) AND (h_count < (hd + hf + hr)) ELSE '1';
    vsync_reg <= '0' WHEN (v_count >= (vd + vf)) AND (v_count < (vd + vf + vr)) ELSE '1';

    -- Activa la señal de dibujo unicamente si los contadores estan dentro del 640x480
    video_on <= '1' WHEN (h_count < hd) AND (v_count < vd) ELSE '0';

    -- Conecta las señales internas con los pines de salida del modulo
    hsync   <= hsync_reg;
    vsync   <= vsync_reg;
    pixel_x <= std_logic_vector(h_count);
    pixel_y <= std_logic_vector(v_count);
    p_tick  <= pixel_tick;

END behavioral;