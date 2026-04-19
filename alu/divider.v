module divider(
  input [15:0]dividend, //deimpartitul
  input [7:0]divisor, //impartitor
  output [7:0]quotient, //cat
  output [7:0]remainder, //rest
  output flag_cnt, //semnaleaza starea modulului (1 = calcul in desfasurare; trece in 0 cand s-a obtinut rezultatul final)
  input clk, start, rst, //clk este pentru ciclul de tact si start este pentru a semnaliza inceperea impartirii, folosit pentru initializare
  output div_zero_err
  ); 
  
  wire [7:0]A, Q, M;
  wire [7:0]A_in, Q_in, M_in;
  wire [3:0]CNT; //contorul care indica cand se termina algoritmul
  
  wire [7:0]difference; //stocheaza diferenta
  wire [7:0]A_shifted; 
  wire no_borrow; //semnalizeaza daca operatia de scadere a fost finalizata cu sau fara imprumut
  
  wire under_8;
  assign div_zero_err = (divisor == 8'b0);
  assign under_8 = (CNT < 8);

  //daca sel=0 (nu e eroare), flag_cnt urmeaza contorul (under_8)
  //daca sel=1 (e eroare), flag_cnt este fortat pe 0 (stop)
  mux2_1#(.w(1)) mux_stop_on_err (.i0(under_8), .i1(1'b0), .sel(div_zero_err), .out(flag_cnt));
  
  assign A_shifted = {A[6:0], Q[7]}; //A_shifted este A shiftat cu o pozitie la stanga
  //pregateste noul rest partial pentru a testa daca impartitorul incape in el
    
  //modulul ripple carry adder e folosit pentru a realiza operatia de diferenta
  rca#(.w(8)) subtracter(.a(A_shifted), .b(~M), .cin(1'b1), .sum(difference), .cout(no_borrow)); //diferenta se calculeaza complementand bitii lui M si cu carry in 1; practic se face adunarea dintre A si -M (transformat in C2)
  
  wire [7:0]A_res;
  wire [7:0]Q_res;
  
  mux2_1#(.w(8)) mux_restore_A(.i0(A_shifted), .i1(difference), .sel(no_borrow), .out(A_res)); //decide daca A primeste valoarea restored sau nu
  mux2_1#(.w(8)) mux_bit_Q(.i0({Q[6:0], 1'b0}), .i1({Q[6:0], 1'b1}), .sel(no_borrow), .out(Q_res)); //alegem ultimul bit al lui Q ca fiind opus bitului de semn a lui A (dat de no_borrow)

  //daca suntem la start, alegem datele de intrare, daca nu, datele shiftate
  mux2_1#(.w(8)) mux_init_A(.i0(A_res), .i1(dividend[15:8]), .sel(start), .out(A_in));
  mux2_1#(.w(8)) mux_init_Q(.i0(Q_res), .i1(dividend[7:0]),  .sel(start), .out(Q_in));

  wire ld_en = start | flag_cnt;
    
  //registrele se incarca la start sau in timpul calculului 
  register#(.w(8)) reg_A(.clk(clk), .load(ld_en), .d(A_in), .q(A));
  register#(.w(8)) reg_Q(.clk(clk), .load(ld_en), .d(Q_in), .q(Q));
  register#(.w(8)) reg_M(.clk(clk), .load(start), .d(divisor), .q(M)); //M se incarca doar la inceput pentru ca nu i se schimba valoarea
  
  counter_4bit cnt(.clk(clk), .start(start), .under_8(flag_cnt), .count(CNT), .rst(rst));
  
  wire done;
  assign done = (CNT == 4'd7); //activ doar cand am terminat cei 7 pasi

  register#(.w(8)) res_latch_q (.clk(clk), .load(done | div_zero_err), .d(Q_in), .q(quotient));
  register#(.w(8)) res_latch_r (.clk(clk), .load(done | div_zero_err), .d(A_in), .q(remainder));
  //produsul final se afla prin concatenarea lui A si Q
  //se încarca doar când done == 1

endmodule 
