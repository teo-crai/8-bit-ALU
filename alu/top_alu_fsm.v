module top_alu_fsm(
  input clk, rst, //semnale de tact si reset
  input b, e, load, //begin -> operatia poate incepe; end -> operatia s-a terminat cu succes; load -> se incarca urmatorul set de intrari
  input [1:0] op_code, //codul care va fi decodat pentru a indica operatia dorita
  input [7:0] x, y,  //operanzii
  output [15:0] rez, //rezultatul
  output div_zero_err
);

  // fire interne (legatura FSM -> ALU)
  wire c_add, c_sub, c_mult, c_div;
  wire write_enable;
  
  wire [15:0] alu_rez_intern; // Fir temporar pentru ce calculeaza ALU
  
  wire [7:0] x_reg, y_reg;
  register #(.w(8)) rx(.clk(clk), .load(load), .rst(rst), .d(x), .q(x_reg));
  register #(.w(8)) ry(.clk(clk), .load(load), .rst(rst), .d(y), .q(y_reg));

  // instanta FSM
  fsm control_unit(
    .clk(clk),
    .rst(rst),
    .b(b),
    .e(e),
    .load(load),
    .op_code(op_code),
    .c_add(c_add),
    .c_sub(c_sub),
    .c_mult(c_mult),
    .c_div(c_div),
    .write_enable(write_enable)
  );

  // instanta ALU
  alu datapath(
    .clk(clk),
    .rst(rst),
    .c_add(c_add),
    .c_sub(c_sub),
    .c_mult(c_mult),
    .c_div(c_div),
    .x(x_reg),
    .y(y_reg),
    .rez(alu_rez_intern),
    .ready(),
    .div_zero_err(div_zero_err)
  );
  
  register #(.w(16)) reg_iesire(
    .clk(clk),
    .load(write_enable),
    .rst(rst),
    .d(alu_rez_intern),
    .q(rez)
  );

endmodule

module top_alu_fsm_tb;

  reg clk, rst;
  reg b, e, load;
  reg [1:0] op_code;
  reg [7:0] x, y;
  
  wire div_zero_err;
  wire [15:0] rez;

  // DUT
  top_alu_fsm dut(
    .clk(clk),
    .rst(rst),
    .b(b),
    .e(e),
    .load(load),
    .op_code(op_code),
    .x(x),
    .y(y),
    .rez(rez),
    .div_zero_err(div_zero_err)
  );

  // clock
  always #5 clk = ~clk;

  // =========================
  // TASK GENERAL PENTRU OPERATII
  // =========================
  // =========================
  // TASK GENERAL PENTRU OPERATII
  // =========================
  task run_operation;
    input [1:0] op;
    input [7:0] a, b_in;
    begin
      // 1. Incarcam datele pe NEGEDGE (evita race conditions)
      @(negedge clk);
      load = 1;
      x = a;
      y = b_in;
      op_code = op;

      @(negedge clk);
      load = 0;

      // 2. Dam impulsul de START pe NEGEDGE
      @(negedge clk);
      b = 1;
      @(negedge clk);
      b = 0;
      
      // 3. Asteptam ca FSM sa ajunga la ST_WRITE (starea 7)
      wait (dut.control_unit.st == 4'd7);
      
      // Un mic buffer pentru a ne asigura ca datele au ajuns pe iesire
      @(posedge clk);
      @(negedge clk);
      
      // 4. Afisare rezultat
      case(op)
        2'b00:
          $display("ADD: %0d + %0d = %0d", a, b_in, rez);
        2'b01:
          $display("SUB: %0d - %0d = %0d", a, b_in, rez);
        2'b10:
          $display("MULT: %0d * %0d = %0d", a, b_in, rez);
        2'b11:
          if (div_zero_err)
             $display("DIV: %0d / %0d = ERROR DIV BY ZERO", a, b_in);
          else
             $display("DIV: %0d / %0d = cat=%0d rest=%0d", a, b_in, rez[7:0], rez[15:8]);
      endcase
      
      @(negedge clk);
      e = 1;
      @(negedge clk);
      e = 0;
      
      // pauza intre operatii
      repeat(2) @(negedge clk);
    end
  endtask

  // =========================
  // INITIAL
  // =========================
  initial begin
    $display("===== TEST COMPLET FSM + ALU =====");

    clk = 0;
    rst = 1;
    b = 0;
    e = 0;
    load = 0;
    op_code = 0;
    x = 0;
    y = 0;

    // reset
    #20 rst = 0;

    // =========================
    // TESTE ADD
    // =========================
    run_operation(2'b00, 10, 5);
    run_operation(2'b00, 0, 0);        // limita
    run_operation(2'b00, 255, 1);      // overflow

    // =========================
    // TESTE SUB
    // =========================
    run_operation(2'b01, 20, 7);
    run_operation(2'b01, 5, 10);       // negativ (underflow)
    run_operation(2'b01, 0, 0);

    // =========================
    // TESTE MULT
    // =========================
    run_operation(2'b10, 6, 4);
    run_operation(2'b10, 0, 123);      // zero
    run_operation(2'b10, 255, 2);      // mare

    // =========================
    // TESTE DIV
    // =========================
    run_operation(2'b11, 40, 6);
    run_operation(2'b11, 100, 10);
    run_operation(2'b11, 5, 1);
    run_operation(2'b11, 5, 0);        // div by zero (important!)

    // =========================
    $display("===== END TEST =====");
    $stop;
  end

endmodule