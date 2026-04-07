library verilog;
use verilog.vl_types.all;
entity alu is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        c_add           : in     vl_logic;
        c_sub           : in     vl_logic;
        c_mult          : in     vl_logic;
        c_div           : in     vl_logic;
        x               : in     vl_logic_vector(7 downto 0);
        y               : in     vl_logic_vector(7 downto 0);
        rez             : out    vl_logic_vector(15 downto 0)
    );
end alu;
