module alu(
    input clk, rst,
    input c_add, c_sub, c_mult, c_div, //selecteaza operatia
    input [7:0] x, y,
    output [15:0] rez,
    output ready, //pt a vedea cand s-a terminat procesul
    output div_zero_err //in cazul in care se imparte cu 0
);

    //detectie front
    wire c_mult_prev, c_div_prev;

    //memoram starea comenzilor din ciclul de tact anterior 
    dff_reset ff_mult(.clk(clk), .rst(rst), .d(c_mult), .q(c_mult_prev));
    dff_reset ff_div(.clk(clk), .rst(rst), .d(c_div),  .q(c_div_prev));

    //semnale pentru cand incepe inmultirea/impartirea; trebuie sa astepte sa se termine cea de dinainte
    wire start_mult = c_mult & ~c_mult_prev;
    wire start_div  = c_div  & ~c_div_prev;
    
    wire load_cmd = c_add | c_sub | c_mult | c_div; //decide daca trebuie sa transmita o comanda
    wire l_sub, l_mult, l_div;
    
    //instantiem DFF-urile cu mux integrat direct la portul 'd'
    //daca load_cmd e 1, 'd' primeste noua comanda; daca nu, primeste vechea comanda ('l_')
    dff_reset ff_lsub  (.clk(clk), .rst(rst), .d(load_cmd ? c_sub  : l_sub),  .q(l_sub));
    dff_reset ff_lmult (.clk(clk), .rst(rst), .d(load_cmd ? c_mult : l_mult), .q(l_mult));
    dff_reset ff_ldiv  (.clk(clk), .rst(rst), .d(load_cmd ? c_div  : l_div),  .q(l_div));
    
    //comanda activa acum, fara intarziere 
    wire act_sub  = load_cmd ? c_sub  : l_sub;
    wire act_mult = load_cmd ? c_mult : l_mult;
    wire act_div  = load_cmd ? c_div  : l_div;
    
    //alu e ready doar cand nu avem opeartii active
    wire busy_mult, busy_div;
    assign ready = ~((busy_mult & act_mult) | (busy_div & act_div)); //e gata daca niciunul nu e ocupat

    //instantiere unitati de calcul
    wire [7:0] add_sum;
    wire add_cout;

    //complementul de 2 pentru scadere (y xor c_sub)
    //A - B = A + (~B) + 1
    wire [7:0] y_inv = y ^ {8{act_sub}};
    
    //instantiere modul de adunare/scadere
    rca #(.w(8)) add_inst(.a(x), 
                          .b(y_inv), 
                          .cin(c_sub), 
                          .sum(add_sum), 
                          .cout(add_cout));

    //instantiere modul de inmultire
    wire [15:0] mult_prod;
    multiplier mult_inst(.a(x), 
                         .b(y), 
                         .clk(clk), 
                         .start(start_mult), 
                         .prod(mult_prod), 
                         .flag_cnt(busy_mult), 
                         .rst(rst));

    //instantiere modul de impartire
    wire [7:0] q, r;
    divider div_inst(.clk(clk), 
                     .start(start_div), 
                     .dividend({8'b0, x}), 
                     .divisor(y), .quotient(q), 
                     .remainder(r), .flag_cnt(busy_div), 
                     .div_zero_err(div_zero_err), 
                     .rst(rst));

    //logica de selectie
    wire [15:0] mux_add_sub_val = {8'b0, add_sum};
    wire [15:0] mux_div_val = {r, q};
    
    wire [15:0] out_mux1;
    wire [15:0] out_mux2;

    //mux-ul 1 alege intre add/sub si multiplier
    //daca c_mult e 1, alege produsul, altfel alege suma
    mux2_1 #(.w(16)) m1(.i0(mux_add_sub_val), 
                        .i1(mult_prod), 
                        .sel(act_mult), 
                        .out(out_mux1));

    //mux-ul 2 alege intre rezultatul anterior si divider
    //daca c_div e 1, alege catul/restul, altfel ramane selectia anterioara
    mux2_1 #(.w(16)) m2(.i0(out_mux1), 
                        .i1(mux_div_val), 
                        .sel(act_div), 
                        .out(out_mux2));

    //folosim act_div si act_mult (semnalele mentinute) pentru a nu pierde rezultatul 
    assign rez = c_div ? mux_div_val : c_mult ? mult_prod : mux_add_sub_val;
    
endmodule

module alu_tb;
    reg clk, rst;
    reg c_add, c_sub, c_mult, c_div;
    reg [7:0] x, y;
    wire [15:0] rez;
    wire ready;
    wire div_zero_err;
    
    alu uut (.clk(clk), .rst(rst), .c_add(c_add), .c_sub(c_sub), .c_mult(c_mult), .c_div(c_div), .x(x), .y(y), .rez(rez), .ready(ready), .div_zero_err(div_zero_err));
    
    always #5 clk = ~clk;

    //op: 0 = add, 1 = sub, 2 = mult, 3 = div
    task execute_alu(input [1:0] op, input [7:0] val_x, input [7:0] val_y);
        begin
            @(negedge clk);
            x = val_x;
            y = val_y;
            
            //activam doar semnalul corespunzator
            case(op)
                2'b00: c_add  = 1;
                2'b01: c_sub  = 1;
                2'b10: c_mult = 1;
                2'b11: c_div  = 1;
            endcase

            @(negedge clk); //asteptam un tact pentru ca alu sa detecteze frontul/load
            
            if (op >= 2'b10) begin//daca e inmultire sau impartire asteptam mai mult sa se termine 
                @(posedge clk);
                wait(ready == 1);
                @(negedge clk);
            end
            else begin
                @(negedge clk); //add si sub sunt instantanee
            end

            //afisare
            case(op)
                2'b00: $display("%d + %d = %d", val_x, val_y, rez);
                2'b01:  $display("%d - %d = %d", val_x, val_y, rez);
                2'b10: $display("%d * %d = %d", $signed(val_x), $signed(val_y), $signed(rez));
                2'b11:  begin
                        if (div_zero_err)
                          $display("ERROR: Division with 0 detected: %d / %d !", val_x, val_y);
                        else
                          $display("%d / %d = %d remainder %d", val_x, val_y, rez[7:0], rez[15:8]);
                        end
                default: $display("Operation not supported");
            endcase

            //resetare semnale de control
            {c_add, c_sub, c_mult, c_div} = 4'b0000;
            
            @(negedge clk); //buffer intre operatii
        end
    endtask

    initial begin
        //initializare
        clk = 0; 
        rst = 0;
        {c_add, c_sub, c_mult, c_div} = 4'b0000;
        x = 0; 
        y = 0;
        
        //reset hardware
        rst = 1;
        #20 
        rst = 0;
        #20 

        $display("--Testing--");

        execute_alu(2'b00, 10, 5);  // Add: 10 + 5
        execute_alu(2'b01, 20, 7);  // Sub: 20 - 7
        execute_alu(2'b10, 6, 4);   // Mult: 6 * 4
        execute_alu(2'b11, 40, 6);  // Div: 40 / 6
        execute_alu(2'b10, -8'd5, 8'd3); //Mult: -5 * 3
        execute_alu(2'b11, 25, 0); //Div cu 0
        
        $display("--Done--");
        $finish;
    end

endmodule