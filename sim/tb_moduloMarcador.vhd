LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_moduloMarcador IS
END tb_moduloMarcador;

ARCHITECTURE sim OF tb_moduloMarcador IS

    COMPONENT moduloMarcador
        PORT (
            clk_50mhz : IN std_logic;
            reset     : IN std_logic;
            score_p1  : IN std_logic;
            score_p2  : IN std_logic;
            hex_p1    : OUT std_logic_vector(6 DOWNTO 0);
            hex_p2    : OUT std_logic_vector(6 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL clk_50mhz : std_logic := '0';
    SIGNAL reset     : std_logic := '0';
    SIGNAL score_p1  : std_logic := '0';
    SIGNAL score_p2  : std_logic := '0';
    SIGNAL hex_p1    : std_logic_vector(6 DOWNTO 0);
    SIGNAL hex_p2    : std_logic_vector(6 DOWNTO 0);

    CONSTANT clk_period : time := 20 ns;

BEGIN
    uut: moduloMarcador PORT MAP (
        clk_50mhz => clk_50mhz, reset => reset,
        score_p1 => score_p1, score_p2 => score_p2,
        hex_p1 => hex_p1, hex_p2 => hex_p2
    );

    -- Generador de reloj a 50 MHz
    clk_process: PROCESS
    BEGIN
        clk_50mhz <= '0'; WAIT FOR clk_period / 2;
        clk_50mhz <= '1'; WAIT FOR clk_period / 2;
    END PROCESS;

    -- Proceso de estímulos
    stim_proc: PROCESS
    BEGIN
        reset <= '0'; WAIT FOR 100 ns;
        reset <= '1'; WAIT FOR 100 ns;

        -- 1. Un gol para el Jugador 1
        score_p1 <= '1'; WAIT FOR clk_period; score_p1 <= '0';
        WAIT FOR 50 ns;

        -- 2. Dos goles rápidos para el Jugador 2
        score_p2 <= '1'; WAIT FOR clk_period; score_p2 <= '0';
        WAIT FOR 50 ns;
        score_p2 <= '1'; WAIT FOR clk_period; score_p2 <= '0';
        WAIT FOR 50 ns;

        -- 3. Prueba de reinicio (rollover): Sumamos 9 goles más al Jugador 1
        FOR i IN 1 TO 9 LOOP
            score_p1 <= '1'; WAIT FOR clk_period; score_p1 <= '0';
            WAIT FOR 50 ns;
        END LOOP;

        WAIT;
    END PROCESS;
END sim;