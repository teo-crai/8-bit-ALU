library verilog;
use verilog.vl_types.all;
entity mux2_1 is
    generic(
        w               : integer := 8
    );
    port(
        i0              : in     vl_logic_vector;
        i1              : in     vl_logic_vector;
        sel             : in     vl_logic;
        \out\           : out    vl_logic_vector
    );
end mux2_1;
