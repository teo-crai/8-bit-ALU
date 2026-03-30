module multiplier(
  output [15:0]prod,
  output flag_cnt,
  input [7:0]a, b,
  input clk, start
  );
  
  reg [7:0]A, Q, M;
  reg Q_1;
  reg [3:0] CNT;
  
  wire [7:0]sum, difference;
  
  always @(posedge clk)
  begin
    if (start) begin
      A <= 8'b0;
      M <= a;
      Q <= b;
      Q_1 <= 1'b0;
      CNT <= 4'b0;
    end
    else begin
      case ({Q[0], Q_1})
        2'b0_1: {A, Q, Q_1} <= {sum[7], sum, Q}; 
        2'b1_0: {A, Q, Q_1} <= {difference[7], difference, Q};
        default: {A, Q, Q_1} <= {A[7], A, Q};
      endcase
      CNT <= CNT + 1'b1;
    end
  end
  
  rca#(.w(8)) adder(.a(A), .b(M), .cin(1'b0), .sum(sum), .cout());
  rca#(.w(8)) subtracter(.a(A), .b(~M), .cin(1'b1), .sum(difference), .cout());
  
  assign prod = {A, Q};
  assign flag_cnt = (CNT < 8);
  
endmodule 
