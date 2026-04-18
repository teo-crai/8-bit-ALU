module counter_4bit(
    input clk,
    input start, //semnal care indica daca trebuie initializat contorul
    input under_8, //semnal care indica daca counter a atins sau nu valoare >8
    output reg [3:0]count //contorul
    );
    
    always @(posedge clk) begin
        if (start) //daca e la inceput initializam
          count <= 4'b0;
        else if (under_8) //daca e sub 8, adunam 1 pentru a mai face un pas de algoritm
          count <= count + 1'b1;
    end
    
endmodule
