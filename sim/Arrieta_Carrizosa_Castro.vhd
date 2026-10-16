LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Arrieta_Carrizosa_Castro IS
    PORT (
        clk_50mhz : IN std_logic;
        reset     : IN std_logic;

        -- Entradas del teclado PS/2
        ps2_clk   : IN std_logic;
        ps2_data  : IN std_logic;

        -- Salidas al monitor VGA
        vga_r     : OUT std_logic_vector(7 DOWNTO 0);
        vga_g     : OUT std_logic_vector(7 DOWNTO 0);
        vga_b     : OUT std_logic_vector(7 DOWNTO 0);
        vga_hs    : OUT std_logic;
        vga_vs    : OUT std_logic;
        
        -- Señales de control de video de la FPGA
        vga_blank : OUT std_logic; 
        vga_sync  : OUT std_logic; 
        vga_clk   : OUT std_logic; 

        -- Salidas a los displays de 7 segmentos del marcador
        hex_p1    : OUT std_logic_vector(6 DOWNTO 0);
        hex_p2    : OUT std_logic_vector(6 DOWNTO 0)
    );
END Arrieta_Carrizosa_Castro;

ARCHITECTURE estructural OF Arrieta_Carrizosa_Castro IS

    -- Señales internas para interconectar los modulos
    SIGNAL scan_code  : std_logic_vector(7 DOWNTO 0);
    SIGNAL scan_ready : std_logic;
    SIGNAL read_ack   : std_logic;

    SIGNAL p1_up      : std_logic;
    SIGNAL p1_down    : std_logic;
    SIGNAL p2_up      : std_logic;
    SIGNAL p2_down    : std_logic;

    SIGNAL pixel_x    : std_logic_vector(9 DOWNTO 0);
    SIGNAL pixel_y    : std_logic_vector(9 DOWNTO 0);
    SIGNAL video_on   : std_logic;
    SIGNAL p_tick     : std_logic;

    SIGNAL score_p1   : std_logic;
    SIGNAL score_p2   : std_logic;

BEGIN

    -- 1. Valores fijos requeridos por el monitor
    vga_blank <= '1';
    vga_sync  <= '0';
    vga_clk   <= p_tick;

    -- 2. Modulo de lectura del teclado
    inst_teclado: ENTITY work.moduloTeclado
        PORT MAP (
            clock       => ps2_clk,
            data        => ps2_data,
            clock_50Mhz => clk_50mhz,
            reset       => reset,
            read1       => read_ack,
            scan_code   => scan_code,
            scan_ready  => scan_ready
        );

    -- 3. Modulo decodificador de los botones del juego
    inst_decodificador: ENTITY work.moduloDecodificador
        PORT MAP (
            clk        => clk_50Mhz,
            rst        => reset,
            scan_code  => scan_code,
            scan_ready => scan_ready,
            read_ack   => read_ack,
            p1_up      => p1_up,
            p1_down    => p1_down,
            p2_up      => p2_up,
            p2_down    => p2_down
        );

    -- 4. Modulo controlador de tiempos del VGA
    inst_vga: ENTITY work.moduloVGA
        PORT MAP (
            clk_50mhz => clk_50Mhz,
            reset     => reset,
            hsync     => vga_hs,
            vsync     => vga_vs,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            video_on  => video_on,
            p_tick    => p_tick
        );

    -- 5. Modulo principal de fisica y graficos
    inst_logica: ENTITY work.moduloLogica
        PORT MAP (
            clk_50mhz => clk_50Mhz,
            reset     => reset,
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            video_on  => video_on,
            p1_up     => p1_up,
            p1_down   => p1_down,
            p2_up     => p2_up,
            p2_down   => p2_down,
            vga_r     => vga_r,
            vga_g     => vga_g,
            vga_b     => vga_b,
            score_p1  => score_p1,
            score_p2  => score_p2
        );

    -- 6. Modulo del marcador en los displays
    inst_marcador: ENTITY work.moduloMarcador
        PORT MAP (
            clk_50mhz => clk_50Mhz,
            reset     => reset,
            score_p1  => score_p1,
            score_p2  => score_p2,
            hex_p1    => hex_p1,
            hex_p2    => hex_p2
        );

END estructural;