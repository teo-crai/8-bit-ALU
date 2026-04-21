module dff_reset (input clk, rst, d, output reg q);
    always @(posedge clk or posedge rst) begin //incarcaam pe frontul pozitiv, in rest 0
        if (rst) 
          q <= 1'b0;
        else 
          q <= d;
    end
endmodule