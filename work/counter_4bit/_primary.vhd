library verilog;
use verilog.vl_types.all;
entity counter_4bit is
    port(
        clk             : in     vl_logic;
        start           : in     vl_logic;
        under_8         : in     vl_logic;
        count           : out    vl_logic_vector(3 downto 0)
    );
end counter_4bit;
