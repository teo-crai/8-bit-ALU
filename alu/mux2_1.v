module mux2_1 #(parameter w = 8) (
    input [w-1:0]i0, i1, //inputurile din care selectam unul
    input sel, //selectorul
    output [w-1:0]out //iesirea
);
    assign out = sel ? i1 : i0; //selectam valoarea iesirii in functie de selector
endmodule
