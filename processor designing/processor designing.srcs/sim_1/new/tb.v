`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2023 11:31:06 AM
// Design Name: 
// Module Name: tb
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
//////////////////////////////////////////////////////////////////////////////////
//////////////////mera
module tb();

reg clk=0,sys_rst=0;
reg [15:0] din=0;
wire [15:0] dout;

top dut(clk,sys_rst,din,dout);

always #5 clk=~clk;

initial begin
sys_rst=1'b1;
repeat(5) @(posedge clk);
sys_rst=1'b0;
# 1800;
$stop;
end

//////////////////////////////udemy

//module tb;
 
 
//integer i = 0;
 
//reg clk = 0,sys_rst = 0;
//reg [15:0] din = 0;
//wire [15:0] dout;
 
 
//top dut(clk, sys_rst, din, dout);
 
//always #5 clk = ~clk;
 
//initial begin
//sys_rst = 1'b1;
//repeat(5) @(posedge clk);
//sys_rst = 1'b0;
//#1800;
//$stop;
//end
 
//endmodule


/*
module tb;

integer i=0;

top dut();
initial
begin
for(i=0;i<32;i=i+1)
dut.GPR[i]=2;
end


initial
begin
/////////////////////// Testbench for Register addition
dut.IR=0;
dut.`imm_mode=0;
dut.`oper_type=2;
dut.`rsrc1=4;
dut.`rsrc2=5;
dut.`rdst=0;
#10;
$display("Register addition -> Rsrc1: %0d,  Rsrc2: %0d,  Rdst: %0d",dut.GPR[4],dut.GPR[5],dut.GPR[0]);
$display("--------------------------------------------------------------------------------------------");

////////////////////Testbench for Immediate addition
dut.IR=0;
dut.`imm_mode=1;
dut.`oper_type=2;
dut.`rsrc1=2;
dut.`rdst=0;
dut.`isrc=4;
#10;
$display("OP:Immediate addition -> Rsrc1: %0d,  immediate value: %0d,  Rdst: %0d",dut.GPR[2],dut.`isrc,dut.GPR[0]);
$display("--------------------------------------------------------------------------------------------");

////////////////////Immediate mov
dut.IR=0;
dut.`imm_mode=1;
dut.`oper_type=1;
dut.`isrc=55;
dut.`rdst=4;
#10;
$display("Immediate move -> Isrc: %0d,  Rdst: %0d",dut.`isrc,dut.GPR[4]);
$display("--------------------------------------------------------------------------------------------");

////////////////////// Register movs
dut.IR=0;
dut.`imm_mode=0;
dut.`oper_type=1;
dut.`rsrc1=7;
dut.`rdst=4;
#10;
$display("Register move -> src1: %0d,  Rdst: %0d",dut.GPR[7],dut.GPR[4]);
$display("--------------------------------------------------------------------------------------------");

////////////////////////////Multiplication
dut.IR=0;
dut.`oper_type=4;
dut.`imm_mode=0;
dut.`rsrc1=0;
dut.`rsrc2=1;
dut.`rdst=2;
#10;
$display("Multiplication LSB -> Rsrc1: %0d,  Rsrc2: %0d,  Rdst(LSB): %0d",dut.GPR[0],dut.GPR[1],dut.GPR[2]);
//#1;
dut.`oper_type=0;
dut.`rdst=3;
#10;
$display("Multiplication MSB -> Rdst(MSB): %0d",dut.GPR[3]);
$display("--------------------------------------------------------------------------------------------");

/////////////////////////////////////OR GATE Immediate
dut.IR=0;
dut.`oper_type=5;
dut.`imm_mode=1;
dut.`rsrc1=7;
dut.`rdst=4;
dut.`isrc=56;
#10;
$display("Or Immediate -> Rdst: %16b,  Isrc: %16b,  Rsrc: %16b",dut.GPR[4],dut.`isrc,dut.GPR[7]);
$display("--------------------------------------------------------------------------------------------");

/////////////////////////////////////OR GATE Register
dut.IR=0;
dut.`oper_type=5;
dut.`imm_mode=0;
dut.`rsrc1=4;
dut.`rdst=0;
dut.`rsrc2=16;
#10;
$display("Or Register -> Rdst: %16b,  Rsrc1: %16b,  Rsrc2: %16b",dut.GPR[0],dut.GPR[4],dut.GPR[16]);
$display("--------------------------------------------------------------------------------------------");

/////////////////////////////////////And GATE
dut.IR=0;
dut.`oper_type=6;
dut.`imm_mode=1;
dut.`rsrc1=7;
dut.`rdst=5;
dut.`isrc=56;
#10;
$display("And Immediate -> Rdst: %16b,  Isrc: %16b,  Rsrc: %16b",dut.GPR[5],dut.`isrc,dut.GPR[7]);
$display("--------------------------------------------------------------------------------------------");

/////////////////////////////////////NOR GATE Register
dut.IR=0;
dut.`oper_type=10;
dut.`imm_mode=0;
dut.`rsrc1=2;
dut.`rdst=0;
dut.`rsrc2=16;
#10;
$display("NOr Register -> Rdst: %16b,  Rsrc1: %16b,  Rsrc2: %16b",dut.GPR[0],dut.GPR[2],dut.GPR[16]);
$display("--------------------------------------------------------------------------------------------");

/////////////////////////////////////NOT GATE Register
dut.IR=0;
dut.`oper_type=11;
dut.`imm_mode=0;
dut.`rsrc1=4;
dut.`rdst=0;
#10;
$display("NOT Register -> Rdst: %16b,  Rsrc1: %16b",dut.GPR[0],dut.GPR[4]);
$display("--------------------------------------------------------------------------------------------");


/////////////////////////// zero flag
dut.IR  = 0;
dut.GPR[0] = 0;
dut.GPR[1] = 0; 
dut.`imm_mode = 0;
dut.`rsrc1 = 0;//gpr[0]
dut.`rsrc2 = 1;//gpr[1]
dut.`oper_type = 2;
dut.`rdst = 2;
#10;
$display("OP:Zero Rsrc1:%0d  Rsrc2:%0d Rdst:%0d ZERO FLAG:%0d",dut.GPR[0], dut.GPR[1], dut.GPR[2],dut.zero );
$display("-----------------------------------------------------------------");
 
//////////////////////////sign flag
dut.IR = 0;
dut.GPR[0] = 16'h8000; /////1000_0000_0000_0000
dut.GPR[1] = 0; 
dut.`imm_mode = 0;
dut.`rsrc1 = 0;//gpr[0]
dut.`rsrc2 = 1;//gpr[1]
dut.`oper_type = 2;
dut.`rdst = 2;
#10;
$display("OP:Sign Rsrc1:%0d  Rsrc2:%0d Rdst:%0d  Sign flag:%d",dut.GPR[0], dut.GPR[1], dut.GPR[2],dut.sign );
$display("-----------------------------------------------------------------");
 
////////////////////////carry flag
dut.IR = 0;
dut.GPR[0] = 16'h8000; /////1000_0000_0000_0000   <0
dut.GPR[1] = 16'h8002; /////1000_0000_0000_0010   <0
dut.`imm_mode = 0;
dut.`rsrc1 = 0;//gpr[0]
dut.`rsrc2 = 1;//gpr[1]
dut.`oper_type = 2;
dut.`rdst = 2;    //////// 0000_0000_0000_0010  >0
#10;
 
$display("OP:Carry & Overflow Rsrc1:%0d  Rsrc2:%0d Rdst:%0d,carry flag: %d,overflow flag: %d",dut.GPR[0], dut.GPR[1], dut.GPR[2],dut.carry,dut.overflow );
$display("-----------------------------------------------------------------");
 
#20;
$finish;
end
endmodule
*/
