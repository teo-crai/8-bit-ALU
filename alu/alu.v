module alu(
    input clk, rst,
    input c_add, c_sub, c_mult, c_div,
    input [7:0] x, y,
    output [15:0] rez
);

    // --- 1. Detectie front---
    wire c_mult_prev, c_div_prev;

    dff_reset ff_mult (.clk(clk), .rst(rst), .d(c_mult), .q(c_mult_prev));
    dff_reset ff_div  (.clk(clk), .rst(rst), .d(c_div),  .q(c_div_prev));

    wire start_mult = c_mult & ~c_mult_prev;
    wire start_div  = c_div  & ~c_div_prev;

    // --- 2. Instantiere Unitati de Calcul ---
    wire [7:0] add_sum;
    wire add_cout;
    
    //complementul de 2 pentru scadere (Y xor c_sub)
    wire [7:0] y_inv = y ^ {8{c_sub}};

    rca #(.w(8)) add_inst(
        .a(x),
        .b(y_inv),
        .cin(c_sub), 
        .sum(add_sum),
        .cout(add_cout)
    );

    wire [15:0] mult_prod;
    multiplier mult_inst(
        .a(x), .b(y), .clk(clk), .start(start_mult),
        .prod(mult_prod), .flag_cnt() // flag_cnt nefolosit aici
    );

    wire [7:0] q, r;
    divider div_inst(
        .clk(clk), .start(start_div),
        .dividend({8'b0, x}), .divisor(y),
        .quotient(q), .remainder(r), .flag_cnt()
    );

    // --- 3. Logica de Selectie ---
    wire [15:0] mux_add_sub_val = {8'b0, add_sum};
    wire [15:0] mux_div_val = {r, q};
    
    wire [15:0] out_mux1;
    wire [15:0] out_mux2;

    // Mux 1: Alege intre Add/Sub si Multiplier
    // Daca c_mult e 1, alege produsul, altfel alege suma
    mux2_1 #(.w(16)) m1 (
        .i0(mux_add_sub_val), 
        .i1(mult_prod), 
        .sel(c_mult), 
        .out(out_mux1)
    );

    // Mux 2: Alege intre rezultatul anterior si Divider
    // Daca c_div e 1, alege catul/restul, altfel ramane selectia anterioara
    mux2_1 #(.w(16)) m2 (
        .i0(out_mux1), 
        .i1(mux_div_val), 
        .sel(c_div), 
        .out(out_mux2)
    );

    // --- 4. Registrul Final ---
    // Determin?m când s? înc?rc?m rezultatul: oricare comand? e activ?
    wire load_rez = c_add | c_sub | c_mult | c_div;
    
    // Folosim registrul pentru iesire
    register #(.w(16)) reg_final (
        .clk(clk), 
        .load(load_rez), 
        .d(out_mux2), 
        .q(rez)
    );

endmodule

module alu_tb;
  reg clk, rst;
  reg c_add, c_sub, c_mult, c_div;
  reg [7:0]x;
  reg [7:0]y;
  wire [15:0]rez;
  
  alu cut(
    .clk(clk),
    .rst(rst),
    .c_add(c_add),
    .c_sub(c_sub),
    .c_mult(c_mult),
    .c_div(c_div),
    .x(x),
    .y(y),
    .rez(rez)
    );
    
    always #5 clk = ~clk; //perioada de 10 ns
    
    initial begin
    $display("Testbench...");
    
    clk = 0;
    rst = 0;
    c_add = 0;
    c_sub = 0;
    c_mult = 0;
    c_div = 0;
    x = 0;
    y = 0;
    
    //reset initial
    #20;
    rst = 1;
    
    //adunare
    #10;
    x = 8'd10;
    y = 8'd5;
    c_add = 1;
    
    #20;
    $display("x=%d y=%d | rez=%d (0x%b)", x, y, rez, rez);
    c_add = 0;
    
    //scadere
    #20;
    x = 8'd20;
    y = 8'd7;
    c_sub = 1;
    
    #20;
    $display("x=%d y=%d | rez=%d (0x%b)", x, y, rez, rez);
    c_sub = 0;
    
    //produs
    #20;
    x = 8'd6;
    y = 8'd4;
    c_mult = 1;
    
    #120;   //mai multe cicluri
    $display("x=%d y=%d | rez=%d (0x%b)", x, y, rez, rez);
    c_mult = 0;
    
    //impartire
    #20;
    x = 8'd40;
    y = 8'd6;
    c_div = 1;
  
    #120;
    $display("x=%d y=%d | cat=%d, rest=%d", x, y, rez[7:0], rez[15:8]);
    c_div = 0;
    
    //$finish;
  end
endmodule
