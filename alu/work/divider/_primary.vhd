library verilog;
use verilog.vl_types.all;
entity divider is
    port(
        dividend        : in     vl_logic_vector(15 downto 0);
        divisor         : in     vl_logic_vector(7 downto 0);
        quotient        : out    vl_logic_vector(7 downto 0);
        remainder       : out    vl_logic_vector(7 downto 0);
        flag_cnt        : out    vl_logic;
        clk             : in     vl_logic;
        start           : in     vl_logic;
        rst             : in     vl_logic;
        div_zero_err    : out    vl_logic
    );
end divider;
