module multiplier(
  output [15:0]prod, //rezultatul final al produsului
  output flag_cnt //semnaleaza starea modulului (1 = calcul in desfasurare; trece in 0 cand s-a obtinut rezultatul final)
  input [7:0]a, b, //numerele care se inmultesc
  input clk, start //clk este pentru ciclul de tact si start este pentru a semnaliza inceperea inmutlirii, folosit pentru initializare
  );
  
  reg [7:0]A, Q, M; 
  reg Q_1; //bitul Q[-1] pentru stabilirea urmatoarei operatii efecutate in algoritm
  reg [3:0] CNT; //contorul care indica cand se termina algoritmul
  
  wire [7:0]sum, difference; //se pastreaza suma si diferenta efecutata la fiecare pas printr-un ripple carry adder
  
  always @(posedge clk) //la fiecare ciclu de tact pe frontul pozitiv
  begin
    if (start) begin 
      A <= 8'b0; //acumulator in care se efectueaza operatiile de adunare/scadere
      M <= a; //M si Q sunt cele 2 numere care trebuie inmultite
      Q <= b;
      Q_1 <= 1'b0; //Q[-1] e initial 0
      CNT <= 4'b0; //contorul se initializeaza pe 0
    end
    else begin
      case ({Q[0], Q_1}) //analizam bitii 0 si -1 pentru a decide urmatoarea operatie
        2'b0_1: {A, Q, Q_1} <= {sum[7], sum, Q}; //cazul 01, se efectueaza adunarea dintre A si M si se shifteaza {A, Q} la dreapta cu o pozitie
        2'b1_0: {A, Q, Q_1} <= {difference[7], difference, Q}; //cazul 10, se efectueaza scaderea lui M din A si se shifteaza {A, Q} la dreapta cu o pozitie
        default: {A, Q, Q_1} <= {A[7], A, Q}; //cazul 00 sau 11, nu se efectueaza operatie, doar se shifteaza {A, Q} cu o pozitie la dreapta
      endcase
      CNT <= CNT + 1'b1; //la fiecare pas din algoritm se creste contorul cu 1
    end
  end

  //modulul ripple carry adder e folosit pentru a realiza operatia de suma sau diferenta
  rca#(.w(8)) adder(.a(A), .b(M), .cin(1'b0), .sum(sum), .cout()); //suma se calculeaza normal, cu carry in 0
  rca#(.w(8)) subtracter(.a(A), .b(~M), .cin(1'b1), .sum(difference), .cout()); //diferenta se calculeaza complementand bitii lui M si cu carry in 1; practic se face adunarea dintre A si -M (transformat in C2)
  
  assign prod = {A, Q}; //produsul final se afla prin concatenarea lui A si Q
  assign flag_cnt = (CNT < 8); 
  
endmodule 
