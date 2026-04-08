module divider(
  input [15:0]dividend, //deimpartitul
  input [7:0]divisor, //impartitor
  output [7:0]quotient, //cat
  output [7:0]remainder, //rest
  output flag_cnt, //semnaleaza starea modulului (1 = calcul in desfasurare; trece in 0 cand s-a obtinut rezultatul final)
  input clk, start //clk este pentru ciclul de tact si start este pentru a semnaliza inceperea impartirii, folosit pentru initializare
  ); 
  
  reg [7:0]A, Q, M;
  reg [3:0]CNT; //contorul care indica cand se termina algoritmul
  
  wire [7:0]difference; //stocheaza diferenta
  wire [7:0]A_shifted; 
  wire no_borrow; //semnalizeaza daca operatia de scadere a fost finalizata cu sau fara imprumut
  
  assign A_shifted = {A[6:0], Q[7]}; //A_shifted este A shiftat cu o pozitie la stanga
  //pregateste noul rest partial pentru a testa daca impartitorul incape in el

  //modulul ripple carry adder e folosit pentru a realiza operatia de diferenta
  rca#(.w(8)) subtracter(.a(A_shifted), .b(~M), .cin(1'b1), .sum(difference), .cout(no_borrow)); //diferenta se calculeaza complementand bitii lui M si cu carry in 1; practic se face adunarea dintre A si -M (transformat in C2)
  
  always @(posedge clk) //la fiecare ciclu de tact pe frontul pozitiv
  begin
  //verificam daca impartitorul (M) a incaput in restul partial (A_shifted)
    if (start) begin
      A <= dividend[15:8]; //deimpartitul este pe 16 biti, jumatatea cea mai semnificativa e in A, iar cea nesemnificativa in Q
      M <= divisor; //M e impartitorul
      Q <= dividend[7:0]; 
      CNT <= 4'b0; //contorul se initializeaza pe 0
    end
    else if (CNT < 8) begin
      if (no_borrow == 1'b0) begin //daca carry out e 0, inseamna ca nu s-a produs un imprumut deci rezultatul e negativ
        A <= A_shifted; //daca rezultatul diferentei e negativ, trebuie efectuata operatia A = A + M (practic ajunge tot la A initial), pentru a restaura A
        Q <= {Q[6:0], 1'b0}; //Q este si el shiftat, adaugandu-se un bit de 0 la final
      end
      else begin //carry out e 1, deci s-a produs un imprumut, rezultatul fiind pozitiv
        A <= difference; //daca rezulatul diferentei e pozitiv, A ajunge sa fie rezulatul diferentei (nu trebuie facut restoring)
        Q <= {Q[6:0], 1'b1}; //Q este shiftat, adaugandu-se un bit de 1 la final
      end 
      CNT <= CNT + 1'b1; //la fiecare pas din algoritm se creste contorul cu 1
    end
  end
  
  assign quotient = Q; 
  assign remainder = A;
  assign flag_cnt = (CNT < 8);
  
endmodule 
