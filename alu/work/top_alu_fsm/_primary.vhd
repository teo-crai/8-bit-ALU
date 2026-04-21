library verilog;
use verilog.vl_types.all;
entity top_alu_fsm is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        b               : in     vl_logic;
        e               : in     vl_logic;
        load            : in     vl_logic;
        op_code         : in     vl_logic_vector(1 downto 0);
        x               : in     vl_logic_vector(7 downto 0);
        y               : in     vl_logic_vector(7 downto 0);
        rez             : out    vl_logic_vector(15 downto 0);
        div_zero_err    : out    vl_logic
    );
end top_alu_fsm;
