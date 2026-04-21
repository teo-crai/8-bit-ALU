module fsm(
  input clk,rst,b,e,load, //b->begin, e->end
  input [1:0]op_code, //codul care indica ce operatie se doreste a fi efectuata
  output reg c_add, c_sub, c_mult, c_div,
  output reg write_enable
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
  reg [1:0] op_latched; //pentru a memora operatia si a mentine semnalele active in starea de scriere
  reg [3:0] wait_cnt; //contor pentru operatiile lungi

  always @(posedge clk or negedge rst) begin
        if (rst) 
          op_latched <= 2'b00;
        else if (st == ST_LOAD) 
          op_latched <= op_code;
  end
    
  always @(posedge clk or posedge rst) begin
    if (rst) 
      wait_cnt <= 0;
    else if (st == ST_DECODE) begin  
          if (op_latched == 2'b10 || op_latched == 2'b11) 
              wait_cnt <= 8; //setam asteptarea la 8 cicluri
          else 
              wait_cnt <= 0;
      end
      else if (wait_cnt > 0) 
        wait_cnt <= wait_cnt - 1;
  end
    
  //blocul secvential, memoria automatului
  always @ (posedge clk or posedge rst) begin //actualizeaza starea pe fiecare front pozitiv de tact; reset asincron, activ pe 0
    if(rst) 
      st<=ST_RST; 
    else 
      st<=st_next;
   end

   //blocul combinational pentru tranzitii
   always @ (*) begin
     st_next = st; //initializare a starii urmatoare
     write_enable=0;
     case(st) //se stabileste urmatoare stare pentru fiecare posibilitate de stare curenta
      ST_RST: if(b) st_next=ST_BEGIN; //din reset trecem in begin
      ST_BEGIN: st_next=ST_LOAD; //din begin trecem in load
      ST_LOAD: st_next=ST_DECODE; //din load trecem in decode, decodarea codului operatiei
      ST_DECODE:case(op_latched)
                    2'b00: st_next = ST_ADD;
                    2'b01: st_next = ST_SUB;
                    2'b10: st_next = ST_MULT;
                    2'b11: st_next = ST_DIV;
                 endcase
      ST_ADD: st_next=ST_WRITE; //din adunare/scadere trecem direct in write, scrierea in outbus
      ST_SUB: st_next=ST_WRITE;
      ST_MULT:   if(wait_cnt == 0) st_next = ST_WRITE; 
      ST_DIV:    if(wait_cnt == 0) st_next = ST_WRITE;
      ST_WRITE:  if(e) st_next = ST_END;
      ST_END:    st_next = ST_RST;
      default: st_next=ST_RST;
    endcase
   end

   //blocul combinational pentru iesiri
  always @(*) begin
        {c_add, c_sub, c_mult, c_div} = 4'b0000;
        write_enable = 0;
        case(st)
            ST_ADD:   c_add  = 1;
            ST_SUB:   c_sub  = 1;
            ST_MULT:  c_mult = 1;
            ST_DIV:   c_div  = 1;
            ST_WRITE: begin
                write_enable = 1;
                // Mentinem semnalul activ pentru ca ALU MUX sa ramana pe pozitia corecta
                case(op_latched)
                    2'b00: c_add  = 1;
                    2'b01: c_sub  = 1;
                    2'b10: c_mult = 1;
                    2'b11: c_div  = 1;
                endcase
            end
        endcase
    end
    
  always @(posedge clk) begin
        if (rst) begin // Rulam debug doar cand NU suntem in reset
            $display("[FSM Debug] Timp:%0t | Stare:%0d | op:%b | cmd(ASMD):%b%b%b%b | asteapta:%0d", 
                     $time, st, op_latched, c_add, c_sub, c_mult, c_div, wait_cnt);
        end
    end
    
 endmodule