module register #(parameter w = 8) (
    input clk, load, rst,
    input [w-1:0]d,
    output reg [w-1:0]q
);
    always @(posedge clk or posedge rst) begin//cand suntem pe frontul pozitiv
      if(rst) 
        q <= 0;
      else if (load)  //si semnalul de load e activ, incarcam registrul
        q <= d;
    end
endmodule