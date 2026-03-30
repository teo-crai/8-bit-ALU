module fac(
  input a, b, cin, 
  output sum, cout
  );
  assign sum=(a^b^cin);
  assign cout=((a&b)|(b&cin)|(a&cin));
endmodule

module rca#(parameter w)(
  input [w-1:0]a,
  input [w-1:0]b,
  input cin,
  output reg [w-1:0]sum,
  output reg cout
  );
  wire [w:0]c_aux;
  assign c_aux[0]=cin;
  genvar i;
  generate
  for(i=0;i<w;i=i+1) begin: v
    fac f1(.a(a[i]),.b(b[i]),.cin(c_aux[i]),.sum(sum[i]),.cout(c_aux[i+1]));
  end
  endgenerate
  assign cout=c_aux[w];
endmodule
