library verilog;
use verilog.vl_types.all;
entity rca is
    generic(
        w               : integer := 8
    );
    port(
        a               : in     vl_logic_vector;
        b               : in     vl_logic_vector;
        cin             : in     vl_logic;
        sum             : out    vl_logic_vector;
        cout            : out    vl_logic
    );
end rca;
