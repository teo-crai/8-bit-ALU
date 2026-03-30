module fsm(
  input clk,rst,b,e,load, //b->begin, e->end
  input op_code, //codul care indica ce operatie se doreste a fi efectuata
  output reg c_add,c_sub,c_mult,c_div
  );
  localparam ST_BEGIN=3'd0;
  localparam ST_LOAD=3'd1;
  localparam ST_DECODE=3'd2;
  localparam ST_ADD=3'd3;
  localparam ST_SUB=3'd4;
  localparam ST_MULT=3'd5;
  localparam ST_DIV=3'd6;
  localparam ST_WRITE=3'd7;
  localparam ST_END=3'd8;
  localparam ST_RST=3'd9;
  reg [2:0]st;
  reg [2:0]st_next;
  always @ (posedge clk, negedge rst)
    if(!rst) st_next<=ST_RST;
    else st<=st_next;
   always @ (*) begin
     case(st)
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
   end
   always @ (*) begin 
     case(st)
       ST_ADD: {c_add,c_sub,c_mult,c_div}=4'b1000;
       ST_SUB: {c_add,c_sub,c_mult,c_div}=4'b0100;
       ST_MULT: {c_add,c_sub,c_mult,c_div}=4'b0010;
       ST_DIV: {c_add,c_sub,c_mult,c_div}=4'b0001;
   end
 endmodule