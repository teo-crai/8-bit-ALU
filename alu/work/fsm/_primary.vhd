library verilog;
use verilog.vl_types.all;
entity fsm is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        b               : in     vl_logic;
        e               : in     vl_logic;
        load            : in     vl_logic;
        op_code         : in     vl_logic;
        c_add           : out    vl_logic;
        c_sub           : out    vl_logic;
        c_mult          : out    vl_logic;
        c_div           : out    vl_logic
    );
end fsm;
