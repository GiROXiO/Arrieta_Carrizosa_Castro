library ieee;
use ieee.std_logic_1164.all;

entity tb_moduloTeclado is
end tb_moduloTeclado;

architecture sim of tb_moduloTeclado is

    component moduloTeclado
        port (
            clock        : in  std_logic;
            data         : in  std_logic;
            clock_50MHz  : in  std_logic;
            reset        : in  std_logic;
            read1        : in  std_logic;
            scan_code    : out std_logic_vector(7 downto 0);
            scan_ready   : out std_logic
        );
    end component;

    signal clk_50M    : std_logic := '0';
    signal ps2_clk    : std_logic := '1';
    signal ps2_data   : std_logic := '1';
    signal rst        : std_logic := '0';
    signal rd1        : std_logic := '0';
    signal s_code     : std_logic_vector(7 downto 0);
    signal s_ready    : std_logic;

    procedure send_ps2_byte(
        byte_in : in std_logic_vector(7 downto 0);
        signal p_clk : out std_logic;
        signal p_data : out std_logic
    ) is
        variable parity : std_logic;
    begin
        parity := not (byte_in(0) xor byte_in(1) xor byte_in(2) xor byte_in(3) xor
                       byte_in(4) xor byte_in(5) xor byte_in(6) xor byte_in(7));
        
        p_data <= '0'; wait for 5 us; p_clk <= '0'; wait for 30 us; p_clk <= '1'; wait for 30 us;
        for i in 0 to 7 loop
            p_data <= byte_in(i); wait for 5 us; p_clk <= '0'; wait for 30 us; p_clk <= '1'; wait for 30 us;
        end loop;
        p_data <= parity; wait for 5 us; p_clk <= '0'; wait for 30 us; p_clk <= '1'; wait for 30 us;
        p_data <= '1'; wait for 5 us; p_clk <= '0'; wait for 30 us; p_clk <= '1'; wait for 30 us;
    end procedure;

begin

    uut: moduloTeclado port map (
        clock => ps2_clk, data => ps2_data, clock_50MHz => clk_50M,
        reset => rst, read1 => rd1, scan_code => s_code, scan_ready => s_ready
    );

    process begin clk_50M <= '0'; wait for 10 ns; clk_50M <= '1'; wait for 10 ns; end process;

    process
    begin
        rst <= '0'; wait for 100 ns; rst <= '1'; wait for 100 us;
        
        send_ps2_byte(x"1D", ps2_clk, ps2_data);
        wait for 50 us;
        rd1 <= '1'; wait for 1 us; rd1 <= '0'; wait for 100 us;
        
        send_ps2_byte(x"F0", ps2_clk, ps2_data);
        wait until s_ready = '1'; wait for 10 us;
        rd1 <= '1'; wait for 20 us; rd1 <= '0';
        
        wait;
    end process;
end sim;