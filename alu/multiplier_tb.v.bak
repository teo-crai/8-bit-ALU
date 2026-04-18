module tb_multiplier;
  reg [7:0] a;
  reg [7:0] b;
  reg clk;
  reg start;
  
  wire [15:0] prod;
  wire flag_cnt;
  
  multiplier uut (
    .prod(prod), 
    .flag_cnt(flag_cnt), 
    .a(a), 
    .b(b), 
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
    // Test Case 1: Positive * Positive (5 * 7 = 35)
    // ---------------------------------------------
    $display("--- Test 1: 5 * 7 ---");
    a = 8'd5;      // Load multiplicand
    b = 8'd7;      // Load multiplier
    
    start = 1;      
    #10;            
    start = 0;      
    
    wait(flag_cnt == 0);
    #10;
    
    $display("Result: %d * %d = %d (Expected: 35)\n", $signed(a), $signed(b), $signed(prod));

    // ---------------------------------------------
    // Test Case 2: Negative * Positive (-6 * 4 = -24)
    // ---------------------------------------------
    $display("--- Test 2: -6 * 4 ---");
    a = -8'd6;     
    b = 8'd4;      
    
    start = 1;
    #10;
    start = 0;

    wait(flag_cnt == 0);
    #10;
    $display("Result: %d * %d = %d (Expected: -24)\n", $signed(a), $signed(b), $signed(prod));

    // ---------------------------------------------
    // Test Case 3: Negative * Negative (-8 * -3 = 24)
    // ---------------------------------------------
    $display("--- Test 3: -8 * -3 ---");
    a = -8'd8;
    b = -8'd3;
    
    start = 1;
    #10;
    start = 0;

    wait(flag_cnt == 0);
    #10;
    $display("Result: %d * %d = %d (Expected: 24)\n", $signed(a), $signed(b), $signed(prod));

    $display("Simulation complete.");
    $finish;
  end

endmodule
