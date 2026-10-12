library ieee;
use ieee.std_logic_1164.all;

entity tb_moduloDecodificador is
end tb_moduloDecodificador;

architecture sim of tb_moduloDecodificador is

    component moduloDecodificador
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            scan_code  : in  std_logic_vector(7 downto 0);
            scan_ready : in  std_logic;
            read_ack   : out std_logic;
            p1_up      : out std_logic;
            p1_down    : out std_logic;
            p2_up      : out std_logic;
            p2_down    : out std_logic
        );
    end component;

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal scan_code  : std_logic_vector(7 downto 0) := (others => '0');
    signal scan_ready : std_logic := '0';
    signal read_ack   : std_logic;
    signal p1_up      : std_logic;
    signal p1_down    : std_logic;
    signal p2_up      : std_logic;
    signal p2_down    : std_logic;

    -- Procedimiento para emular la llegada de un scan_code desde moduloTeclado
    procedure push_key(
        code : in std_logic_vector(7 downto 0);
        signal s_code : out std_logic_vector(7 downto 0);
        signal s_ready : out std_logic
    ) is
    begin
        s_code  <= code;
        s_ready <= '1';
        wait for 40 ns; -- Dos ciclos de 50 MHz
        s_ready <= '0';
        wait for 60 ns;
    end procedure;

begin

    uut: moduloDecodificador
        port map (
            clk => clk, rst => rst, scan_code => scan_code,
            scan_ready => scan_ready, read_ack => read_ack,
            p1_up => p1_up, p1_down => p1_down,
            p2_up => p2_up, p2_down => p2_down
        );

    -- Reloj de 50 MHz (periodo 20 ns)
    process begin
        clk <= '0'; wait for 10 ns;
        clk <= '1'; wait for 10 ns;
    end process;

    -- Prueba de pulsación y liberación de W
    process
    begin
        rst <= '0'; wait for 50 ns;
        rst <= '1'; wait for 50 ns;

        -- 1. Presiona W (1D) -> p1_up debe subir a '1'
        push_key(x"1D", scan_code, scan_ready);
        wait for 200 ns;

        -- 2. Suelta W (F0 seguido de 1D) -> p1_up debe caer a '0'
        push_key(x"F0", scan_code, scan_ready);
        wait for 100 ns;
        push_key(x"1D", scan_code, scan_ready);
        wait for 200 ns;

        wait;
    end process;

end sim;