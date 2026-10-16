LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_moduloLogica IS
END tb_moduloLogica;

ARCHITECTURE sim OF tb_moduloLogica IS

    COMPONENT moduloLogica
        PORT (
            clk_50mhz : IN std_logic;
            reset     : IN std_logic;
            pixel_x   : IN std_logic_vector(9 DOWNTO 0);
            pixel_y   : IN std_logic_vector(9 DOWNTO 0);
            video_on  : IN std_logic;
            p1_up     : IN std_logic;
            p1_down   : IN std_logic;
            p2_up     : IN std_logic;
            p2_down   : IN std_logic;
            vga_r     : OUT std_logic_vector(7 DOWNTO 0);
            vga_g     : OUT std_logic_vector(7 DOWNTO 0);
            vga_b     : OUT std_logic_vector(7 DOWNTO 0);
            score_p1  : OUT std_logic;
            score_p2  : OUT std_logic
        );
    END COMPONENT;

    -- Señales de entrada
    SIGNAL clk_50mhz : std_logic := '0';
    SIGNAL reset     : std_logic := '0';
    SIGNAL pixel_x   : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL pixel_y   : std_logic_vector(9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL video_on  : std_logic := '0';
    SIGNAL p1_up     : std_logic := '0';
    SIGNAL p1_down   : std_logic := '0';
    SIGNAL p2_up     : std_logic := '0';
    SIGNAL p2_down   : std_logic := '0';
    
    -- Señales de salida
    SIGNAL vga_r     : std_logic_vector(7 DOWNTO 0);
    SIGNAL vga_g     : std_logic_vector(7 DOWNTO 0);
    SIGNAL vga_b     : std_logic_vector(7 DOWNTO 0);
    SIGNAL score_p1  : std_logic;
    SIGNAL score_p2  : std_logic;

    CONSTANT clk_period : time := 20 ns;

BEGIN

    uut: moduloLogica
        PORT MAP (
            clk_50mhz => clk_50mhz, reset => reset,
            pixel_x => pixel_x, pixel_y => pixel_y, video_on => video_on,
            p1_up => p1_up, p1_down => p1_down, p2_up => p2_up, p2_down => p2_down,
            vga_r => vga_r, vga_g => vga_g, vga_b => vga_b,
            score_p1 => score_p1, score_p2 => score_p2
        );

    -- Generador de reloj
    clk_process: PROCESS
    BEGIN
        clk_50mhz <= '0'; WAIT FOR clk_period / 2;
        clk_50mhz <= '1'; WAIT FOR clk_period / 2;
    END PROCESS;

    -- Proceso de estímulos
    stim_proc: PROCESS
    BEGIN
        -- 1. Estado inicial y Reset
        reset <= '0';
        WAIT FOR 100 ns;
        reset <= '1';
        WAIT FOR 100 ns;

        -- 2. Prueba de Física (Movimiento automático de la pelota)
        -- Engañamos al sistema enviando X=0, Y=480 para simular el fin de un cuadro
        pixel_x <= std_logic_vector(to_unsigned(0, 10));
        pixel_y <= std_logic_vector(to_unsigned(480, 10));
        WAIT FOR clk_period; -- Mantenemos el tick por 1 ciclo de reloj
        pixel_x <= std_logic_vector(to_unsigned(10, 10)); -- Quitamos el tick
        WAIT FOR 100 ns;

        -- 3. Prueba de Controles (Movimiento Paleta 1)
        -- Presionamos la flecha "Arriba" y damos otro tick de cuadro
        p1_up <= '1';
        pixel_x <= std_logic_vector(to_unsigned(0, 10));
        pixel_y <= std_logic_vector(to_unsigned(480, 10));
        WAIT FOR clk_period;
        pixel_x <= std_logic_vector(to_unsigned(10, 10));
        p1_up <= '0'; -- Soltamos el boton
        WAIT FOR 100 ns;

        -- 4. Prueba de Renderizado (El Pincel)
        -- Encendemos la pantalla y simulamos que el láser pasa sobre la Paleta 1 (X=33, Y=199)
        video_on <= '1';
        pixel_x <= std_logic_vector(to_unsigned(33, 10));
        pixel_y <= std_logic_vector(to_unsigned(199, 10));
        WAIT FOR 100 ns;

        -- 5. Simulamos que el láser sale de la paleta y pasa a zona vacía (X=100)
        pixel_x <= std_logic_vector(to_unsigned(100, 10));
        WAIT FOR 100 ns;

        WAIT;
    END PROCESS;
END sim;