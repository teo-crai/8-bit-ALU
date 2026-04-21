library verilog;
use verilog.vl_types.all;
entity multiplier is
    port(
        prod            : out    vl_logic_vector(15 downto 0);
        flag_cnt        : out    vl_logic;
        a               : in     vl_logic_vector(7 downto 0);
        b               : in     vl_logic_vector(7 downto 0);
        clk             : in     vl_logic;
        start           : in     vl_logic;
        rst             : in     vl_logic
    );
end multiplier;
