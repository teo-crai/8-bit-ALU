module fac(
  input a, b, cin, 
  output sum, cout
  );
  //formulele obtinute din simplificarea cu harti Karnaugh
  assign sum=(a^b^cin);
  assign cout=((a&b)|(b&cin)|(a&cin));
endmodule

module rca#(parameter w=8)( //modul parametrizabil
  input [w-1:0]a, //a si b sunt termenii sumei
  input [w-1:0]b,
  input cin, //carry in (transportul de intrare)
  output [w-1:0]sum, //suma
  output cout //carry out (transportul de iesire)
  );
  wire [w:0]c_aux; //conecteaza cout-ul unei celule la cin-ul urmatoarei
  assign c_aux[0]=cin;
  genvar i;
  generate
  for(i=0;i<w;i=i+1) begin: v
    fac f1(.a(a[i]),.b(b[i]),.cin(c_aux[i]),.sum(sum[i]),.cout(c_aux[i+1])); //se calculeaza suma bit cu bit folosind modulul full adder cell de w ori
  end
  endgenerate
  assign cout=c_aux[w];
endmodule
