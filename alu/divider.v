module divider(
  input [15:0]dividend,
  input [7:0]divisor,
  output [7:0]quotient,
  output [7:0]remainder,
  output flag_cnt,
  input clk, start
  ); 
  
  reg [7:0]A, Q, M;
  reg [3:0]CNT;
  
  wire [7:0]difference;
  wire [7:0]A_shifted;
  wire no_borrow;
  
  assign A_shifted = {A[6:0], Q[7]};
  
  rca#(.w(8)) subtracter(.a(A_shifted), .b(~M), .cin(1'b1), .sum(difference), .cout(no_borrow));
  
  always @(posedge clk)
  begin
    if (start) begin
      A <= dividend[15:8];
      M <= divisor;
      Q <= dividend[7:0];
      CNT <= 4'b0;
    end
    else if (CNT < 8) begin
      if (no_borrow == 1'b0) begin //negativ
        A <= A_shifted;   
        Q <= {Q[6:0], 1'b0};
      end
      else begin //pozitiv
        A <= difference;
        Q <= {Q[6:0], 1'b1};
      end
      CNT <= CNT + 1'b1;
    end
  end
  
  assign quotient = Q;
  assign remainder = A;
  assign flag_cnt = (CNT < 8);
  
endmodule 
