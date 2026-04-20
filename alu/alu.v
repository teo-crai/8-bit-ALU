module alu(
    input clk, rst,
    input c_add, c_sub, c_mult, c_div,
    input write_enable,
    input [7:0] x, y,
    output flag_mult, flag_div,
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
        .prod(mult_prod), .flag_cnt(flag_mult) // flag_cnt nefolosit aici
    );

    wire [7:0] q, r;
    divider div_inst(
        .clk(clk), .start(start_div),
        .dividend({8'b0, x}), .divisor(y),
        .quotient(q), .remainder(r), .flag_cnt(flag_div)
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
    /*wire load_rez =
    c_add |
    c_sub |
    (c_mult & ~flag_mult) |
    (c_div  & ~flag_div);*/
    wire load_rez = write_enable; //rezultatul se incarca in functie de semnalul determinat de control unit
    
    // Folosim registrul pentru iesire
    register #(.w(16)) reg_final (
        .clk(clk),
        .rst(rst),
        .load(load_rez), 
        .d(out_mux2), 
        .q(rez)
    );

endmodule

module alu_tb;
  reg clk, rst;
  reg c_add, c_sub, c_mult, c_div;
  reg [7:0] x, y;
  wire [15:0] rez;

  // Instantierea ALU
  alu cut (
    .clk(clk), .rst(rst),
    .c_add(c_add), .c_sub(c_sub), .c_mult(c_mult), .c_div(c_div),
    .x(x), .y(y), .rez(rez)
  );

  // Ceas de 10ns (frecventa 100MHz)
  always #5 clk = ~clk;

  // Task pentru executia operatiilor
  task execute_op(input [2:0] type, input [7:0] val_x, input [7:0] val_y);
    begin
      // 1. Preg?tim datele pe frontul negativ
      @(negedge clk);
      x = val_x;
      y = val_y;
      
      // 2. Activ?m comanda (Puls de START)
      case(type)
        1: c_add  = 1;
        2: c_sub  = 1;
        3: c_mult = 1;
        4: c_div  = 1;
      endcase

      // 3. ?inem comanda activ? un ciclu de ceas complet
      @(posedge clk); 
      #2; // Mic delay dup? frontul pozitiv

      // 4. Dezactiv?m comanda
      @(negedge clk);
      {c_add, c_sub, c_mult, c_div} = 4'b0000;

      // 5. A?tept?m mult mai mult (ex: 15 cicluri) pentru a l?sa 
      // algoritmul s? termine ?i s? transfere datele în registrul de ie?ire
      repeat (15) @(posedge clk);
      
      #2; // Sincronizare final? pentru afi?are

      if (type == 4)
        $display("[TIME: %0t] DIV: %d / %d = Cat: %0d, Rest: %0d", $time, val_x, val_y, rez[7:0], rez[15:8]);
      else
        $display("[TIME: %0t] OP:%0d: %d si %d | Rezultat = %0d", $time, type, val_x, val_y, rez);
        
      // 6. Mai a?tept?m pu?in între teste s? se cure?e magistralele
      repeat (2) @(posedge clk);
    end
  endtask

  initial begin
    // Initializare
    clk = 0;
    rst = 0;
    {c_add, c_sub, c_mult, c_div} = 0;
    x = 0; y = 0;

    // Secventa de Reset
    #15 rst = 1; 
    #10;

    $display("--- Start Testbench (8 Cicluri/Op) ---");

    // Teste
    execute_op(1, 8'd10, 8'd5);   // Adunare (de obicei e instanta, dar task-ul asteapta 8 cic)
    execute_op(3, 8'd6,  8'd4);   // Inmultire (8 cicluri)
    execute_op(3, 8'd12, 8'd10);  // Inmultire (8 cicluri)
    execute_op(4, 8'd40, 8'd6);   // Impartire (8 cicluri)
    execute_op(4, 8'd255, 8'd5);  // Impartire (8 cicluri)

    $display("--- Testbench Finalizat ---");
    $stop; 
  end

endmodule
