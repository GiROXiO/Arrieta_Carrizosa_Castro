LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY tb_Arrieta_Carrizosa_Castro IS
END tb_Arrieta_Carrizosa_Castro;

ARCHITECTURE sim OF tb_Arrieta_Carrizosa_Castro IS

    COMPONENT Arrieta_Carrizosa_Castro
        PORT (
            clk_50mhz : IN std_logic;
            reset     : IN std_logic;
            ps2_clk   : IN std_logic;
            ps2_data  : IN std_logic;
            vga_r     : OUT std_logic_vector(7 DOWNTO 0);
            vga_g     : OUT std_logic_vector(7 DOWNTO 0);
            vga_b     : OUT std_logic_vector(7 DOWNTO 0);
            vga_hs    : OUT std_logic;
            vga_vs    : OUT std_logic;
            vga_blank : OUT std_logic;
            vga_sync  : OUT std_logic;
            vga_clk   : OUT std_logic;
            hex_p1    : OUT std_logic_vector(6 DOWNTO 0);
            hex_p2    : OUT std_logic_vector(6 DOWNTO 0)
        );
    END COMPONENT;

    -- Señales de estimulo
    SIGNAL clk_50mhz : std_logic := '0';
    SIGNAL reset     : std_logic := '0';
    SIGNAL ps2_clk   : std_logic := '1'; -- Reposo en alto
    SIGNAL ps2_data  : std_logic := '1'; -- Reposo en alto

    -- Señales de observacion
    SIGNAL vga_r     : std_logic_vector(7 DOWNTO 0);
    SIGNAL vga_g     : std_logic_vector(7 DOWNTO 0);
    SIGNAL vga_b     : std_logic_vector(7 DOWNTO 0);
    SIGNAL vga_hs    : std_logic;
    SIGNAL vga_vs    : std_logic;
    SIGNAL vga_blank : std_logic;
    SIGNAL vga_sync  : std_logic;
    SIGNAL vga_clk   : std_logic;
    SIGNAL hex_p1    : std_logic_vector(6 DOWNTO 0);
    SIGNAL hex_p2    : std_logic_vector(6 DOWNTO 0);

    CONSTANT clk_period : time := 20 ns; -- 50 MHz

BEGIN

    uut: Arrieta_Carrizosa_Castro
        PORT MAP (
            clk_50mhz => clk_50mhz, reset => reset,
            ps2_clk => ps2_clk, ps2_data => ps2_data,
            vga_r => vga_r, vga_g => vga_g, vga_b => vga_b,
            vga_hs => vga_hs, vga_vs => vga_vs,
            vga_blank => vga_blank, vga_sync => vga_sync, vga_clk => vga_clk,
            hex_p1 => hex_p1, hex_p2 => hex_p2
        );

    -- Generador del reloj principal de la tarjeta
    clk_process: PROCESS
    BEGIN
        clk_50mhz <= '0'; WAIT FOR clk_period / 2;
        clk_50mhz <= '1'; WAIT FOR clk_period / 2;
    END PROCESS;

    -- Proceso de encendido
    stim_proc: PROCESS
    BEGIN
        -- 1. Mantener reset presionado al encender
        reset <= '0'; 
        WAIT FOR 100 ns;
        
        -- 2. Soltar reset para que el juego inicie
        reset <= '1'; 
        
        -- 3. Dejar correr la simulación suficiente tiempo para ver señales VGA
        WAIT FOR 40 us; 
        
        WAIT;
    END PROCESS;

END sim;