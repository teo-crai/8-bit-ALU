module fsm(
  input clk,rst,b,e,load, //b->begin, e->end
  input [1:0]op_code, //codul care indica ce operatie se doreste a fi efectuata
  output reg c_add,c_sub,c_mult,c_div
  );
  //codificare pentru fiecare stare
  localparam ST_BEGIN=4'd0; 
  localparam ST_LOAD=4'd1; //se incarca datele in registru
  localparam ST_DECODE=4'd2; //decodeaza operatia care trebuie efectuata
  localparam ST_ADD=4'd3; //starea care indica ca se efectueaza operatia de adunare
  localparam ST_SUB=4'd4; //starea care indica ca se efectueaza operatia de scadere
  localparam ST_MULT=4'd5; //starea care indica ca se efectueaza operatia de inmultire
  localparam ST_DIV=4'd6; //starea care indica ca se efectueaza operatia de impartire
  localparam ST_WRITE=4'd7; //starea care indica ca se afiseaza rezultatele
  localparam ST_END=4'd8; //starea finala
  localparam ST_RST=4'd9; //starea de reset 
  
  reg [3:0]st; //starea curenta
  reg [3:0]st_next; //urmatoarea stare

  //blocul secvential, memoria automatului
  always @ (posedge clk, negedge rst) begin //actualizeaza starea pe fiecare front pozitiv de tact; reset asincron, activ pe 0
    if(!rst) st<=ST_RST; 
    else st<=st_next;
   end

   //blocul combinational pentru tranzitii
   always @ (*) begin
     case(st) //se stabileste urmatoare stare pentru fiecare posibilitate de stare curenta
      ST_RST: if(b) st_next=ST_BEGIN;
      ST_BEGIN: if(load) st_next=ST_LOAD;
      ST_LOAD: st_next=ST_DECODE;
      ST_DECODE: if(op_code==2'b00) st_next=ST_ADD;
                 else if(op_code==2'b01)  st_next=ST_SUB;
                 else if(op_code==2'b10) st_next=ST_MULT;
                 else st_next=ST_DIV;
      ST_ADD: st_next=ST_WRITE;
      ST_SUB: st_next=ST_WRITE;
      ST_MULT: st_next=ST_WRITE;
      ST_DIV: st_next=ST_WRITE;
      ST_WRITE: if(rst) st_next=ST_RST;
                else if(load) st_next=ST_LOAD;
                else if(e) st_next=ST_END;
      default: st_next=ST_RST;
    endcase
   end

   //blocul combinational pentru iesiri
  always @ (*) begin //genereaza semnale de control pe baza starii in care ne aflam
     {c_add, c_sub, c_mult, c_div} = 4'b0000;
     case(st)
       ST_ADD: {c_add,c_sub,c_mult,c_div}=4'b1000; //activeaza adunarea
       ST_SUB: {c_add,c_sub,c_mult,c_div}=4'b0100; //activeaza scaderea
       ST_MULT: {c_add,c_sub,c_mult,c_div}=4'b0010; //activeaza inmultirea
       ST_DIV: {c_add,c_sub,c_mult,c_div}=4'b0001; //activeaza impartirea
     endcase
   end
 endmodule
