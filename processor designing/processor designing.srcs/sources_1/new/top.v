`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2023 05:15:05 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 

///////////fields of IR
`define oper_type IR[31:27]
`define rdst      IR[26:22]
`define rsrc1     IR[21:17]
`define imm_mode  IR[16]
`define rsrc2     IR[15:11]
`define isrc      IR[15:0]
 
 
////////////////arithmetic operation
`define movsgpr        5'b00000
`define mov            5'b00001
`define add            5'b00010
`define sub            5'b00011
`define mul            5'b00100
 

////////////////Logical operations
`define ror             5'b00101
`define rand            5'b00110
`define rxor            5'b00111
`define rxnor           5'b01000
`define rnand           5'b01001
`define rnor            5'b01010
`define rnot            5'b01011
 
//////////////Load and store instruction
`define storereg        5'b01101    ///////store content of  reg in DM
`define storedin        5'b01110    ///////store content of din in DM
`define senddout        5'b01111    ///////send content of DM to out
`define sendreg         5'b10001    ///////send content of DM to reg

///////////////////////Adding jump instructions
`define jump            5'b10010
`define jcarry          5'b10011
`define jnocarry        5'b10100
`define jsign           5'b10101
`define jnosign         5'b10110
`define jzero           5'b10111
`define jnozero         5'b11000
`define joverflow       5'b11001
`define jnooverflow     5'b11010

///////////////////halt
`define halt            5'b11011

module top(
input clk,sys_rst,
input [15:0] din,
output reg [15:0] dout
);
    
reg [31:0] IR;     // 31 bit instruction regigister
reg [15:0] GPR [31:0]; //32 general purpose register each of having 16 bit each.  
    
reg [15:0] SGPR;    // 16 bit special register for higher bits of multiplication
reg [31:0] mul_res; // To store multiplicatipn result

reg [16:0] add;
reg carry=0,sign=0,overflow=0,zero=0;

////////////////////Adding program and data memory
reg [31:0] inst_mem[15:0];  ///////////program memory
reg [15:0] data_mem[15:0];  ///////////data memory

reg jmp_flag=1'b0;
reg stop=1'b0;
///////////////////////////////////////////////////////////////////////////Here is the ALU 
task decode_inst();
begin
jmp_flag=1'b0;
stop=1'b0;

case(`oper_type)
///////////////////   Move sgpr instruction
`movsgpr :
begin
    GPR[`rdst] = SGPR;
end
//////////////  Move instruction
`mov :
begin
    if (`imm_mode)
        GPR[`rdst]=`isrc;
    else
        GPR[`rdst]=GPR[`rsrc1];
end
////////////////// ADD instruction
`add :
begin
    if(`imm_mode)
        begin
            add=GPR[`rsrc1]+ `isrc;
            GPR[`rdst]=add[15:0];
            
        end
    else
        begin
            add=GPR[`rsrc1] + GPR[`rsrc2];
            GPR[`rdst]=add[15:0];
        end
    carry=add[16];
end
////////////////// Subtraction instruction
`sub :
begin
    if(`imm_mode)
        GPR[`rdst]=GPR[`rsrc1] - `isrc;
    else
        GPR[`rdst]=GPR[`rsrc1] - GPR[`rsrc2];    
end
////////////////////// Multiplication instruction
`mul: begin
    if (`imm_mode)  
        mul_res=GPR[`rsrc1] * `isrc;
    else
        mul_res=GPR[`rsrc1] * GPR[`rsrc2];
    
GPR[`rdst]  =       mul_res[15:0];
SGPR        =       mul_res[31:16];
end


////////////////////////////////////////////////////////////////////Adding Logical operations

/////////////////OR gate
`ror: begin
    if(`imm_mode)
        GPR[`rdst]=GPR[`rsrc1] | `isrc;
    else
        GPR[`rdst]=GPR[`rsrc1] | GPR[`rsrc2];
end

////////////////////and gate
`rand: begin
    if(`imm_mode)
        GPR[`rdst]=GPR[`rsrc1] & `isrc;
    else
        GPR[`rdst]=GPR[`rsrc1] & GPR[`rsrc2];
end

////////////////////Xor gate
`rxor: begin
    if(`imm_mode)
        GPR[`rdst]=GPR[`rsrc1] ^ `isrc;
    else
        GPR[`rdst]=GPR[`rsrc1] ^ GPR[`rsrc2];
end

////////////////////Xnor gate
`rxnor: begin
    if(`imm_mode)
        GPR[`rdst]=~(GPR[`rsrc1] ^ `isrc);
    else
        GPR[`rdst]=~(GPR[`rsrc1] ^ GPR[`rsrc2]);
end

////////////////////nand gate
`rnand: begin
    if(`imm_mode)
        GPR[`rdst]=~(GPR[`rsrc1] & `isrc);
    else
        GPR[`rdst]=~(GPR[`rsrc1] & GPR[`rsrc2]);
end

////////////////////nor gate
`rnor: begin
    if(`imm_mode)
        GPR[`rdst]=~(GPR[`rsrc1] | `isrc);
    else
        GPR[`rdst]=~(GPR[`rsrc1] | GPR[`rsrc2]);
end

////////////////////not gate
`rnot: begin
    if(`imm_mode)
        GPR[`rdst]=~(`isrc);
    else
        GPR[`rdst]=~(GPR[`rsrc1]);
end

//////////////////////////////////////////////Loading instruction 
`storereg:
begin
    data_mem[`isrc]=GPR[`rsrc1];    
end

`storedin:
begin
    data_mem[`isrc]=din;
end

`senddout:
begin
    dout=data_mem[`isrc];
end

`sendreg:
begin
    GPR[`rdst]=data_mem[`isrc];
end

//////////////////////////Jumping and branching
`jump:begin
jmp_flag=1'b1;
end

`jcarry:begin
    if(carry)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`jnocarry:begin
    if(~carry)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`jsign:begin
    if(sign)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`jnosign:begin
    if(~sign)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`joverflow:begin
    if(overflow)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`jnooverflow:begin
    if(~overflow)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`jzero:begin
    if(zero)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`jnozero:begin
    if(~zero)
        jmp_flag=1'b1;
    else
        jmp_flag=1'b0;
end

`halt:
begin
stop=1'b1;
end
endcase
end
endtask    
///////////////////////////////////Logic for control unit i.e sign,overflow,carry,zero

/////////////////////////////////////Making control using
task decode_condflag();
begin

//////////////////////////zero flag
    if(`oper_type==`mul)
        zero=~(|SGPR|(|GPR[`rdst]));
    else
        zero=~(|GPR[`rdst]);
     
////////////////////////////////sign flag
     if(`oper_type==`mul)
        sign=SGPR[15];
     else
        sign=GPR[`rdst][15];     
        
/////////////////////////carry flag        
    //////Done in addition logic
    
///////////////////////////////overflow
if(`oper_type==`add)
    begin
        if(`imm_mode)
            overflow=((GPR[`rsrc1][15])&(IR[15])&~(GPR[`rdst][15]))|(~(GPR[`rsrc1][15])&~(IR[15])&(GPR[`rdst][15]));
        else
            overflow=((GPR[`rsrc1][15])&(GPR[`rsrc2][15])&~(GPR[`rdst][15]))|(~(GPR[`rsrc1][15])&~(GPR[`rsrc2][15])&(GPR[`rdst][15]));        
    end
    
else if(`oper_type==`sub)
    begin
        if(`imm_mode)
            overflow=(~(GPR[`rsrc1][15])&(IR[15])&(GPR[`rdst][15])) | ((GPR[`rsrc1][15])&~(IR[15])&~(GPR[`rdst][15]));
        else
            overflow=(~(GPR[`rsrc1][15])&(GPR[`rsrc2][15])&(GPR[`rdst][15])) | ((GPR[`rsrc1][15])&~(GPR[`rsrc2][15])&~(GPR[`rdst][15]));            
    end
else
    overflow=1'b0;
end    

endtask    

///////////////////////////////////////////////////////////////
/////////////////////////////////
///////////////////////////////////////////////////////Reading program
initial
begin
$readmemb("mul_of_6x5_via_adding_jump_instr.mem",inst_mem); /////////////////loading our program in instruction memory
end 

///////////////////Reading instruction one after another
reg [2:0] count=0;
integer pc=0;

//always@(posedge clk)
//begin
//    if(sys_rst)
//        begin
//            count<=0;
//            pc<=0;
//        end
//    else
//        begin
//            if(count<4)
//                count<=count+1;
//            else
//                begin
//                    count<=0;
//                    pc<=pc+1;
//                end  
//        end 
//end

//////////////////////////Reading instruction

//always@(*)
//    begin
//        if(sys_rst)
//            IR=0;
//        else
//            begin
//                IR=inst_mem[pc];
//                decode_inst();
//                decode_condflag();
//            end
//    end


/////////////////////////////////////////////////////////////////////////Implementing by FSM
parameter idle=0,fetch_inst=1,dec_exec_inst=2,next_inst=3,sense_halt=4,delay_next_inst=5;
reg [2:0] state=idle,next_state=idle;

///////////////////we will need 3 always block 1 to reset i.e sequential 2nd to update states it is combinational 3rd is for giving delay it has to be sequential

/////////1st always block to reset
always@(posedge clk)
begin
    if(sys_rst)
        state<=0;
    else
        state<=next_state;
end

/////////2nd always block to update states and performing all operations
always@(*)
begin
    case(state)
idle:begin
    IR=32'b0;     
    pc=0;
    next_state=fetch_inst;    
end

fetch_inst:begin
    IR=inst_mem[pc];
    next_state=dec_exec_inst;
end

dec_exec_inst:begin
    decode_inst();
    decode_condflag();
    next_state=delay_next_inst;
end    

delay_next_inst:begin
    if(count<4)
        next_state=delay_next_inst;
    else
        next_state=next_inst;
    end
 
next_inst:begin
    next_state=sense_halt;
    if(jmp_flag)
        pc=`isrc;
    else
        pc=pc+1;    
    end 
    
sense_halt:begin
    if(~stop)
        next_state=fetch_inst;
    else if(sys_rst)
        next_state=idle;
    else
        next_state=sense_halt;
    end 

default:
next_state=idle;
endcase
end

////////////3rd always block to delay as it is in combinational so we can't define there
always @(posedge clk)
    begin
    case(state)
delay_next_inst:begin
    count<=count+1;
end

default:
count<=0;

    endcase
end

endmodule





///////////////////////////////////////////////////////////UDEMY

//`timescale 1ns / 1ps
 
/////////////fields of IR
//`define oper_type IR[31:27]
//`define rdst      IR[26:22]
//`define rsrc1     IR[21:17]
//`define imm_mode  IR[16]
//`define rsrc2     IR[15:11]
//`define isrc      IR[15:0]
 
 
//////////////////arithmetic operation
//`define movsgpr        5'b00000
//`define mov            5'b00001
//`define add            5'b00010
//`define sub            5'b00011
//`define mul            5'b00100
 
//////////////////logical operations : and or xor xnor nand nor not
 
//`define ror            5'b00101
//`define rand           5'b00110
//`define rxor           5'b00111
//`define rxnor          5'b01000
//`define rnand          5'b01001
//`define rnor           5'b01010
//`define rnot           5'b01011
 
///////////////////////// load & store instructions
 
//`define storereg       5'b01101   //////store content of register in data memory
//`define storedin       5'b01110   ////// store content of din bus in data memory
//`define senddout       5'b01111   /////send data from DM to dout bus
//`define sendreg        5'b10001   ////// send data from DM to register
 
/////////////////////////////// Jump and branch instructions
//`define jump           5'b10010  ////jump to address
//`define jcarry         5'b10011  ////jump if carry
//`define jnocarry       5'b10100
//`define jsign          5'b10101  ////jump if sign
//`define jnosign        5'b10110
//`define jzero          5'b10111  //// jump if zero
//`define jnozero        5'b11000
//`define joverflow      5'b11001 ////jump if overflow
//`define jnooverflow    5'b11010
 
////////////////////////////halt 
//`define halt           5'b11011
 
 
 
//module top(
//input clk,sys_rst,
//input [15:0] din,
//output reg [15:0] dout
//);
 
//////////////////adding program and data memory
//reg [31:0] inst_mem [15:0]; ////program memory
//reg [15:0] data_mem [15:0]; ////data memory
 
 
 
 
 
//reg [31:0] IR;            ////// instruction register  <--ir[31:27]--><--ir[26:22]--><--ir[21:17]--><--ir[16]--><--ir[15:11]--><--ir[10:0]-->
//                          //////fields                 <---  oper  --><--   rdest --><--   rsrc1 --><--modesel--><--  rsrc2 --><--unused  -->             
//                          //////fields                 <---  oper  --><--   rdest --><--   rsrc1 --><--modesel--><--  immediate_date      -->      
 
//reg [15:0] GPR [31:0] ;   ///////general purpose register gpr[0] ....... gpr[31]
 
 
 
//reg [15:0] SGPR ;      ///// msb of multiplication --> special register
 
//reg [31:0] mul_res;
 
 
//reg sign = 0, zero = 0, overflow = 0, carry = 0; ///condition flag
//reg [16:0] temp_sum;
 
//reg jmp_flag = 0;
//reg stop = 0;
 
//task decode_inst();
// begin
   
//jmp_flag = 1'b0;
//stop     = 1'b0;
 
//case(`oper_type)
/////////////////////////////////
//`movsgpr: begin
 
//   GPR[`rdst] = SGPR;
   
//end
 
///////////////////////////////////
//`mov : begin
//   if(`imm_mode)
//        GPR[`rdst]  = `isrc;
//   else
//       GPR[`rdst]   = GPR[`rsrc1];
//end
 
//////////////////////////////////////////////////////
 
//`add : begin
//      if(`imm_mode)
//        GPR[`rdst]   = GPR[`rsrc1] + `isrc;
//     else
//        GPR[`rdst]   = GPR[`rsrc1] + GPR[`rsrc2];
//end
 
///////////////////////////////////////////////////////////
 
//`sub : begin
//      if(`imm_mode)
//        GPR[`rdst]  = GPR[`rsrc1] - `isrc;
//     else
//       GPR[`rdst]   = GPR[`rsrc1] - GPR[`rsrc2];
//end
 
///////////////////////////////////////////////////////////////
 
//`mul : begin
//      if(`imm_mode)
//        mul_res   = GPR[`rsrc1] * `isrc;
//     else
//        mul_res   = GPR[`rsrc1] * GPR[`rsrc2];
        
//     GPR[`rdst]   =  mul_res[15:0];
//     SGPR         =  mul_res[31:16];
//end
 
/////////////////////////////////////////////////////////////// bitwise or
 
//`ror : begin
//      if(`imm_mode)
//        GPR[`rdst]  = GPR[`rsrc1] | `isrc;
//     else
//       GPR[`rdst]   = GPR[`rsrc1] | GPR[`rsrc2];
//end
 
//////////////////////////////////////////////////////////////bitwise and
 
//`rand : begin
//      if(`imm_mode)
//        GPR[`rdst]  = GPR[`rsrc1] & `isrc;
//     else
//       GPR[`rdst]   = GPR[`rsrc1] & GPR[`rsrc2];
//end
 
////////////////////////////////////////////////////////////// bitwise xor
 
//`rxor : begin
//      if(`imm_mode)
//        GPR[`rdst]  = GPR[`rsrc1] ^ `isrc;
//     else
//       GPR[`rdst]   = GPR[`rsrc1] ^ GPR[`rsrc2];
//end
 
////////////////////////////////////////////////////////////// bitwise xnor
 
//`rxnor : begin
//      if(`imm_mode)
//        GPR[`rdst]  = GPR[`rsrc1] ~^ `isrc;
//     else
//        GPR[`rdst]   = GPR[`rsrc1] ~^ GPR[`rsrc2];
//end
 
////////////////////////////////////////////////////////////// bitwisw nand
 
//`rnand : begin
//      if(`imm_mode)
//        GPR[`rdst]  = ~(GPR[`rsrc1] & `isrc);
//     else
//       GPR[`rdst]   = ~(GPR[`rsrc1] & GPR[`rsrc2]);
//end
 
//////////////////////////////////////////////////////////////bitwise nor
 
//`rnor : begin
//      if(`imm_mode)
//        GPR[`rdst]  = ~(GPR[`rsrc1] | `isrc);
//     else
//       GPR[`rdst]   = ~(GPR[`rsrc1] | GPR[`rsrc2]);
//end
 
//////////////////////////////////////////////////////////////not
 
//`rnot : begin
//      if(`imm_mode)
//        GPR[`rdst]  = ~(`isrc);
//     else
//        GPR[`rdst]   = ~(GPR[`rsrc1]);
//end
 
//////////////////////////////////////////////////////////////
 
//`storedin: begin
//   data_mem[`isrc] = din;
//end
 
///////////////////////////////////////////////////////////////
 
//`storereg: begin
//   data_mem[`isrc] = GPR[`rsrc1];
//end
 
///////////////////////////////////////////////////////////////
 
 
//`senddout: begin
//   dout  = data_mem[`isrc]; 
//end
 
///////////////////////////////////////////////////////////////
 
//`sendreg: begin
//  GPR[`rdst] =  data_mem[`isrc];
//end
 
///////////////////////////////////////////////////////////////
 
//`jump: begin
// jmp_flag = 1'b1;
//end
 
//`jcarry: begin
//  if(carry == 1'b1)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
//`jsign: begin
//  if(sign == 1'b1)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
//`jzero: begin
//  if(zero == 1'b1)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
 
//`joverflow: begin
//  if(overflow == 1'b1)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
//`jnocarry: begin
//  if(carry == 1'b0)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
//`jnosign: begin
//  if(sign == 1'b0)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
//`jnozero: begin
//  if(zero == 1'b0)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
 
//`jnooverflow: begin
//  if(overflow == 1'b0)
//     jmp_flag = 1'b1;
//   else
//     jmp_flag = 1'b0; 
//end
 
//////////////////////////////////////////////////////////////
//`halt : begin
//stop = 1'b1;
//end
 
//endcase
 
//end
//endtask
 
 
 
/////////////////////////logic for condition flag
 
 
//task decode_condflag();
//begin
 
///////////////////sign bit
//if(`oper_type == `mul)
//  sign = SGPR[15];
//else
//  sign = GPR[`rdst][15];
 
//////////////////carry bit
 
//if(`oper_type == `add)
//   begin
//      if(`imm_mode)
//         begin
//         temp_sum = GPR[`rsrc1] + `isrc;
//         carry    = temp_sum[16]; 
//         end
//      else
//         begin
//         temp_sum = GPR[`rsrc1] + GPR[`rsrc2];
//         carry    = temp_sum[16]; 
//         end   end
//   else
//    begin
//        carry  = 1'b0;
//    end
 
////////////////////////////zero flag
//    if(`oper_type==`mul)
//        zero=~(|SGPR|(|GPR[`rdst]));
//    else
//        zero=~(|GPR[`rdst]);
   
////////////////////////overflow bit
 
//if(`oper_type == `add)
//     begin
//       if(`imm_mode)
//         overflow = ( (~GPR[`rsrc1][15] & ~IR[15] & GPR[`rdst][15] ) | (GPR[`rsrc1][15] & IR[15] & ~GPR[`rdst][15]) );
//       else
//         overflow = ( (~GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & GPR[`rsrc2][15] & ~GPR[`rdst][15]));
//     end
//  else if(`oper_type == `sub)
//    begin
//       if(`imm_mode)
//         overflow = ( (~GPR[`rsrc1][15] & IR[15] & GPR[`rdst][15] ) | (GPR[`rsrc1][15] & ~IR[15] & ~GPR[`rdst][15]) );
//       else
//         overflow = ( (~GPR[`rsrc1][15] & GPR[`rsrc2][15] & GPR[`rdst][15]) | (GPR[`rsrc1][15] & ~GPR[`rsrc2][15] & ~GPR[`rdst][15]));
//    end 
//  else
//     begin
//     overflow = 1'b0;
//     end
 
//end
//endtask
 
 
 
 
 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
///////////////////////////////////////////////
/////////////reading program
 
//initial begin
//$readmemb("mul_of_6x5_via_adding_jump_instr.mem",inst_mem);
////$readmemb("inst_data.mem",inst_mem);
//end
 
//////////////////////////////////////////////////////
////////////reading instructions one after another
//reg [2:0] count = 0;
//integer PC = 0;
///*
//always@(posedge clk)
//begin
//  if(sys_rst)
//   begin
//     count <= 0;
//     PC    <= 0;
//   end
//   else 
//   begin
//     if(count < 4)
//     begin
//     count <= count + 1;
//     end
//     else
//     begin
//     count <= 0;
//     PC    <= PC + 1;
//     end
// end
//end
//*/
//////////////////////////////////////////////////////
///////////reading instructions 
///*
//always@(*)
//begin
//if(sys_rst == 1'b1)
//IR = 0;
//else
//begin
//IR = inst_mem[PC];
//decode_inst();
//decode_condflag();
//end
//end
//*/
//////////////////////////////////////////////////////
//////////////////////////////////// fsm states
//parameter idle = 0, fetch_inst = 1, dec_exec_inst = 2, next_inst = 3, sense_halt = 4, delay_next_inst = 5;
////////idle : check reset state
/////// fetch_inst : load instrcution from Program memory
/////// dec_exec_inst : execute instruction + update condition flag
/////// next_inst : next instruction to be fetched
//reg [2:0] state = idle, next_state = idle;
//////////////////////////////////// fsm states
 
/////////////////////reset decoder
//always@(posedge clk)
//begin
// if(sys_rst)
//   state <= idle;
// else
//   state <= next_state; 
//end
 
 
////////////////////next state decoder + output decoder
 
//always@(*)
//begin
//  case(state)
//   idle: begin
//     IR         = 32'h0;
//     PC         = 0;
//     next_state = fetch_inst;
//   end
 
//  fetch_inst: begin
//    IR          =  inst_mem[PC];   
//    next_state  = dec_exec_inst;
//  end
  
//  dec_exec_inst: begin
//    decode_inst();
//    decode_condflag();
//    next_state  = delay_next_inst;   
//  end
  
  
//  delay_next_inst:begin
//  if(count < 4)
//       next_state  = delay_next_inst;       
//     else
//       next_state  = next_inst;
//  end
  
//  next_inst: begin
//      next_state = sense_halt;
//      if(jmp_flag == 1'b1)
//        PC = `isrc;
//      else
//        PC = PC + 1;
//  end
  
  
// sense_halt: begin
//    if(stop == 1'b0)
//      next_state = fetch_inst;
//    else if(sys_rst == 1'b1)
//      next_state = idle;
//    else
//      next_state = sense_halt;
// end
  
//  default : next_state = idle;
  
//  endcase
  
//end
 
 
//////////////////////////////////// count update 
 
//always@(posedge clk)
//begin
//case(state)
 
// idle : begin
//    count <= 0;
// end
 
// fetch_inst: begin
//   count <= 0;
// end
 
// dec_exec_inst : begin
//   count <= 0;    
// end  
 
// delay_next_inst: begin
//   count  <= count + 1;
// end
 
//  next_inst : begin
//    count <= 0;
// end
 
//  sense_halt : begin
//    count <= 0;
// end
 
// default : count <= 0;
 
  
//endcase
//end
 
 
 
//endmodule
 
 