module alu(
  input clk, rst,
  input c_add, c_sub, c_mult, c_div, //semnalele care decid operatia
  input [7:0]x, //operanzii
  input [7:0]y,
  output reg [15:0]rez //rezultatul
);

  //detector de front pentru semnalele de start
  //memoram valoarea anterioara a semnalelor pentru a detecta tranzitia de la 0 la 1
  reg c_mult_prev, c_div_prev;
  
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      c_mult_prev <= 1'b0;
      c_div_prev <= 1'b0;
    end else begin
      c_mult_prev <= c_mult;
      c_div_prev <= c_div;
    end
  end

  //semnalul 'start' e 1 logic doar in ciclul de tact in care comanda trece din 0 in 1
  wire start_mult = c_mult & ~c_mult_prev;
  wire start_div  = c_div  & ~c_div_prev;

  //adunare/scadere
  wire [7:0] add_sum; //rezultatul
  wire add_cout; //carry out

  rca #(.w(8)) add_inst(
      .a(x),
      .b(c_sub ? ~y : y), //diferenta in C2
      .cin(c_sub), 
      .sum(add_sum),
      .cout(add_cout)
  );

  //inmultire
  wire [15:0] mult_prod; //rezultatul
  wire mult_flag; //semnalizeaza daca algoritmul s-a terminat

  multiplier mult_inst(
      .a(x),
      .b(y),
      .clk(clk),
      .start(start_mult),
      .prod(mult_prod),
      .flag_cnt(mult_flag)
  );

  //impartire
  wire [7:0] q, r; //catul si restul
  wire div_flag; //semnalizeaza daca algoritmul s-a terminat

  divider div_inst(
      .clk(clk),
      .start(start_div),
      .dividend({8'b0,x}),
      .divisor(y),
      .quotient(q),
      .remainder(r),
      .flag_cnt(div_flag)
  );

  //rezultatul
  always @(posedge clk or negedge rst) begin
    if(!rst)
        rez <= 16'b0;
    else begin
        if(c_add || c_sub)
            rez <= {8'b0, add_sum};

        else if(c_mult)
            rez <= mult_prod;

        else if(c_div)
            rez <= {r, q};
    end
  end
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
    
    $finish;
  end
endmodule
