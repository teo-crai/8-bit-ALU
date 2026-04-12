module top_alu_fsm(
  input clk, rst,
  input b, e, load,
  input [1:0] op_code,
  input [7:0] x, y,
  output [15:0] rez
);

  // fire interne (legatura FSM -> ALU)
  wire c_add, c_sub, c_mult, c_div;

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
    .c_div(c_div)
  );

  // instanta ALU
  alu datapath(
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

endmodule

module top_alu_fsm_tb;

  reg clk, rst;
  reg b, e, load;
  reg [1:0] op_code;
  reg [7:0] x, y;
  wire [15:0] rez;

  // instanta DUT (Device Under Test)
  top_alu_fsm dut(
    .clk(clk),
    .rst(rst),
    .b(b),
    .e(e),
    .load(load),
    .op_code(op_code),
    .x(x),
    .y(y),
    .rez(rez)
  );

  // clock: perioada 10 ns
  always #5 clk = ~clk;

  initial begin
    $display("===== TEST FSM + ALU =====");

    // initializare
    clk = 0;
    rst = 0;
    b = 0;
    e = 0;
    load = 0;
    op_code = 0;
    x = 0;
    y = 0;

    // reset
    #20 rst = 1;

    // =========================
    // START FSM
    // =========================
    #10 b = 1;
    #10 b = 0;

    // =========================
    // TEST ADD (00)
    // =========================
    #10;
    load = 1;
    x = 8'd10;
    y = 8'd5;
    op_code = 2'b00;

    #10 load = 0;

    #50;
    $display("ADD: x=%d y=%d -> rez=%d", x, y, rez);

    // =========================
    // TEST SUB (01)
    // =========================
    #20;
    load = 1;
    x = 8'd20;
    y = 8'd7;
    op_code = 2'b01;

    #10 load = 0;

    #50;
    $display("SUB: x=%d y=%d -> rez=%d", x, y, rez);

    // =========================
    // TEST MULT (10)
    // =========================
    #20;
    load = 1;
    x = 8'd6;
    y = 8'd4;
    op_code = 2'b10;

    #10 load = 0;

    // astept mai mult (algoritm secvential)
    #150;
    $display("MULT: x=%d y=%d -> rez=%d", x, y, rez);

    // =========================
    // TEST DIV (11)
    // =========================
    #20;
    load = 1;
    x = 8'd40;
    y = 8'd6;
    op_code = 2'b11;

    #10 load = 0;

    #150;
    $display("DIV: x=%d y=%d -> cat=%d rest=%d", x, y, rez[7:0], rez[15:8]);

    // =========================
    // END
    // =========================
    #20 e = 1;
    #10 e = 0;

    #20;
    $display("===== END TEST =====");
    $finish;
  end

endmodule