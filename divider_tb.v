module tb_divider;
  reg [15:0] a;
  reg [7:0] b;
  reg clk;
  reg start;
  
  wire [7:0]q;
  wire [7:0]r;
  wire flag_cnt;
  
  divider uut (
    .dividend(a),
    .divisor(b),
    .quotient(q),
    .remainder(r), 
    .flag_cnt(flag_cnt), 
    .clk(clk), 
    .start(start)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0;
    start = 0;
    a = 0;
    b = 0;
    
    #20;

// ---------------------------------------------
    // Test Case 1: 3625/107 
    // ---------------------------------------------
    $display("--- Test 1---");
    a = 16'd3625;      // Load multiplicand
    b = 8'd107;      // Load multiplier
    
    start = 1;      
    #10;            
    start = 0;      
    
    wait(flag_cnt == 0);
    #10;
    
    $display("Result: %d / %d = %d remainder %d (Expected: 33, 94)\n", a, b, q, r);

    // ---------------------------------------------
    // Test Case 2: 5824/99
    // ---------------------------------------------
    $display("--- Test 2---");
    a = 16'd5824;     
    b = 8'd99;      
    
    start = 1;
    #10;
    start = 0;

    wait(flag_cnt == 0);
    #10;
    $display("Result: %d / %d = %d remainder %d (Expected: 58, 82)\n", a, b, q, r);

    $display("Simulation complete.");
    $finish;
  end

endmodule
