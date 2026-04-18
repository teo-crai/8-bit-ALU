module register #(parameter w = 8) (
    input clk, load,
    input [w-1:0]d,
    output reg [w-1:0]q
);
    always @(posedge clk) begin //cand suntem pe frontul pozitiv
        if (load)  //si semnalul de load e activ, incarcam registrul
          q <= d;
    end
endmodule
