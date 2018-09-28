//Jean Santos Silva - 89398

module ff ( input data, input c, input r, output q);
reg q;
always @(posedge c or negedge r) 
begin
 if(r==1'b0)
  q <= 1'b0; 
 else 
  q <= data; 
end 
endmodule //End 

// ----   FSM alto nível com Case
module statem(clk, reset, a, sd);

input clk, reset, a;
output [2:0] sd;
reg [2:0] state;
parameter dois=3'd2, quatro=3'd4, cinco=3'd5, seis=3'd6,  sete=3'd7;

assign sd = state;

always @(posedge clk or negedge reset)
    begin
        if (reset == 0)
            state = dois;
        else
            case (state)
                dois: state = seis;
                cinco: state = quatro;
				sete: state = cinco;
                quatro: if(a) state = seis;
                        else state = dois;
                seis: if(a) state = sete; 
                       else state = cinco;
            endcase
     end
endmodule


module statePorta(input clk, input res, input a, output [2:0] s);
wire [2:0] e;
wire [2:0] p;
assign s = e;  // sd = estado atual
assign p[0] =  e[2]&e[1]; //1 operacão
assign p[1] =  ~e[2] | (~e[1] | ~e[0]) | (~e[0]&~a); //9 operacoes
assign p[2] =  ~e[2] | e[1] | e[0] | a; //4 operacoes
//14 operacoes
ff  e0(p[0],clk,res,e[0]);
ff  e1(p[1],clk,res,e[1]);
ff  e2(p[2],clk,res,e[2]);
endmodule 




module stateMem(input clk,input res, input a, input[2:0] entrada, output [2:0] sd);
reg [5:0] StateMachine [0:15]; 
initial
begin
StateMachine[0] = 6'h10;  StateMachine[8] = 6'h14;
StateMachine[1] = 6'h20;  StateMachine[9] = 6'h34;
StateMachine[3] = 6'h20;  StateMachine[11] = 6'h25;  
StateMachine[2] = 6'h10;  StateMachine[10] = 6'h25;
StateMachine[6] = 6'h10;  StateMachine[14] = 6'h2F;
StateMachine[7] = 6'h20;  StateMachine[15] = 6'h2F;
StateMachine[5] = 6'h32;  StateMachine[13] = 6'h2E;
StateMachine[4] = 6'h32;  StateMachine[12] = 6'h2E;
end
wire [3:0] address;  
wire [5:0] dout; 
assign address[3] = a;
assign dout = StateMachine[address];
assign sd = dout[2:0];
ff st0(dout[3],clk,res,address[0]);
ff st1(dout[4],clk,res,address[1]);
ff st2(dout[5],clk,res,address[2]);
endmodule

module main;
reg c,res,a;
wire [2:0] sd;
wire [2:0] sd1;
wire [2:0] sd2;

statem FSM(c,res,a,sd);
stateMem FSM1(c,res,a,sd1,sd1);
statePorta FSM2(c,res,a,sd2);


initial
    c = 1'b0;
  always
    c= #(1) ~c;


initial  begin
     $dumpfile ("out.vcd"); 
     $dumpvars; 
   end 

  initial
    begin
     $monitor($time," c %b res %b a %b s %d smem %d sporta %d",c,res,a,sd,saida1,saida2);
      #1 res=0; a=0;
      #1 res=1;
      #8 a=1;
      #16 a=0;
      #12 a=1;
      #4;
      $finish ;
    end
endmodule
