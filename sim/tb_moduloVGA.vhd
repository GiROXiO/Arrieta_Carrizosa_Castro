LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_moduloVGA IS
END tb_moduloVGA;

ARCHITECTURE sim OF tb_moduloVGA IS

    COMPONENT moduloVGA
        PORT (
            clk_50Mhz : IN std_logic;
            reset     : IN std_logic;
            hsync     : OUT std_logic;
            vsync     : OUT std_logic;
            pixel_x   : OUT std_logic_vector(9 DOWNTO 0);
            pixel_y   : OUT std_logic_vector(9 DOWNTO 0);
            video_on  : OUT std_logic;
            p_tick    : OUT std_logic
        );
    END COMPONENT;

    SIGNAL clk_50Mhz : std_logic := '0';
    SIGNAL reset     : std_logic := '0';
    SIGNAL hsync     : std_logic;
    SIGNAL vsync     : std_logic;
    SIGNAL pixel_x   : std_logic_vector(9 DOWNTO 0);
    SIGNAL pixel_y   : std_logic_vector(9 DOWNTO 0);
    SIGNAL video_on  : std_logic;
    SIGNAL p_tick    : std_logic;

    -- Periodo para el reloj base de la fpga (50 mhz)
    CONSTANT clk_period : time := 20 ns; 

BEGIN

    uut: moduloVGA
        PORT MAP (
            clk_50Mhz => clk_50Mhz,
            reset     => reset,
            hsync     => hsync,
            vsync     => vsync,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            video_on  => video_on,
            p_tick    => p_tick
        );

    -- Generador de reloj de 50 mhz
    clk_process: PROCESS
    BEGIN
        clk_50Mhz <= '0';
        WAIT FOR clk_period / 2;
        clk_50Mhz <= '1';
        WAIT FOR clk_period / 2;
    END PROCESS;

    -- Proceso de estimulos para la simulacion
    stim_proc: PROCESS
    BEGIN
        reset <= '0'; -- Mantiene el reset activo al inicio
        WAIT FOR 100 ns;
        reset <= '1'; -- Libera el reset para que arranque el sistema

        -- Dejamos correr suficiente tiempo para ver un par de lineas horizontales
        WAIT FOR 70 us;
        WAIT; -- Detiene la simulacion
    END PROCESS;

END sim;