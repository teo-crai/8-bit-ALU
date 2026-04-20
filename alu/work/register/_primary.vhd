library verilog;
use verilog.vl_types.all;
entity \register\ is
    generic(
        w               : integer := 8
    );
    port(
        clk             : in     vl_logic;
        load            : in     vl_logic;
        rst             : in     vl_logic;
        d               : in     vl_logic_vector;
        q               : out    vl_logic_vector
    );
end \register\;
