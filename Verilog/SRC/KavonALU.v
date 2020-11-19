module DFF16(clk,in,out);
   parameter n=16;
   //width
   input clk;
   input [n-1:0] in;
   output [n-1:0] out;
   reg [n-1:0] out;
     always @(posedge clk)
       out = in;
endmodule // DFF16

module Mux16(a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0, s, b);
   parameter k = 16;
   input [k-1:0] a15, a14, a13, a12, a11, a10, a9, a8, a7, a6, a5, a4, a3, a2, a1, a0;
   input [3:0] s; // 4-bit opcode 
   output [k-1:0] b;
   reg [k-1:0] b;
   always @ (*)
     begin
	case(s)
	  4'b0000:b=a15;
	  4'b0001:b=a14;
	  4'b0010:b=a13;
	  4'b0011:b=a12;
	  4'b0100:b=a11;
	  4'b0101:b=a10;
	  4'b0110:b=a9;
	  4'b0111:b=a8;
	  4'b1000:b=a7;
	  4'b1001:b=a6;
	  4'b1010:b=a5;
	  4'b1011:b=a4;
	  4'b1100:b=a3;
	  4'b1101:b=a2;
	  4'b1110:b=a1;
	  4'b1111:b=a0;
	  default:b=4'b0000;
	endcase // case (s)
     end // always @ (*)
   endmodule // Mux16

`define NOOP 4'b0000
`define ADD 4'b0001
`define SUB 4'b0010
`define MULT 4'b0011
`define DIV 4'b0100
`define AND 4'b0101
`define OR 4'b0110
`define XOR 4'b0111
`define NOT 4'b1000
`define RESET 4'b1111 

module ALU(clk, clear, input1, input2, opcode, out);

   parameter w = 16;
   input clk, clear;
   input [w-1:0] input1, input2;
   input [3:0] 	 opcode;
   output [w-1:0] out;
   wire [w-1:0] next, ACC;
   
   DFF16 #(w) stored_output(clk, next, ACC);
   
   wire [w-1:0] modeNOOP = ACC;
   wire [w-1:0] add_val = input1 + input2;
   wire [w-1:0] sub_val = input1 - input2; 
   wire signed [31:0] product = input1 * input2;
   wire [w-1:0] quotient = input1 / input2;
   wire [w-1:0] and_val = input1 & input2;
   wire [w-1:0] or_val = input1 | input2;
   wire [w-1:0] xor_val = input1 ^ input2;
   wire [w-1:0] not_val = ~input1;
   wire [w-1:0] muxPORT9; // UNUSED INPUT
   wire [w-1:0] muxPORT10;// UNUSED INPUT
   wire [w-1:0] muxPORT11;// UNUSED INPUT
   wire [w-1:0] muxPORT12;// UNUSED INPUT
   wire [w-1:0] muxPORT13;// UNUSED INPUT
   wire [w-1:0] muxPORT14;// UNUSED INPUT
   wire [w-1:0] modeRESET = 16'b0000000000000000; //Set DFF to all 0s

   Mux16 choice(modeNOOP, add_val, sub_val, product[15:0], quotient, and_val, or_val, xor_val, not_val, muxPORT9, muxPORT10, muxPORT11, muxPORT12, muxPORT13, muxPORT14, modeRESET, opcode, next);
   
   assign out = next;

endmodule // ALU

module TestBench;
   reg clk, clear;
   parameter n=16;
   reg [n-1:0] input1, input2;
   reg [3:0]   opcode;
   wire [n-1:0] out;

   ALU alu(clk, clear, input1, input2, opcode, out);

   initial begin // Start Thread Output
      #5 clk = 1;
      #5 clk = 0;
	$display("Clock|Clear|INPUT 1                 |INPUT 2                 |OpCode      |OUTPUT                  |");
	$display("-----+-----+------------------------+------------------------+------------+------------------------+");
	    forever
	      begin
		 $display("%b    |%b    |%b (%d)|%b (%d)|%b (%s)|%b (%d)|", clk, clear, input1, input1, input2, input2, opcode, (opcode==4'b0000 ?"NO-OP":(opcode==4'b0001 ?"ADD":(opcode==4'b0010 ?"SUB":(opcode==4'b0011 ?"MULT":(opcode==4'b0100 ?"DIV":(opcode==4'b0101 ?"AND":(opcode==4'b0110 ?"OR":(opcode==4'b0111 ?"XOR":(opcode==4'b1000 ? "NOT":(opcode==4'b1111 ? "RESET":"Nil")))))))))), out, out);
		 
		 #5 clk = 1;
		 #5 clk = 0;
	      end
     end // initial begin

     // input stimuli
     initial begin
	#6
	clear = 0;
	input1=16'b0000000000000000;
	input2=16'b0000000000000001;
	opcode=`NOOP;
	#10
	clear=0;
	input1=16'b0000000000000001;
	input2=16'b0000000000000001;
	opcode=`ADD;
	#10
	  clear = 0;
	input1=16'b0000000000000011;
	input2=16'b0000000000000001;
	opcode=`SUB;
	#10
	  clear=0;
	input1=16'b0000000000000010;
	input2=16'b0000000000000010;
	opcode=`MULT;
	#10
	  clear=0;
	input1=16'b0000000000001000;
	input2=16'b0000000000000010;
	opcode=`DIV;
	#10
	  clear=0;
	input1=16'b0000000000001111;
	input2=16'b0000000000001001;
	opcode=`AND;
	#10
	  clear=0;
	input1=16'b0000000000001010;
	input2=16'b0000000000000101;
	opcode=`OR;
	#10
	  clear=0;
	input1=16'b0000000000001011;
	input2=16'b0000000000001101;
	opcode=`XOR;
	#10
	  clear=0;
	input1=16'b1111111111111111;
	input2=16'b1111111111111111;
	opcode=`NOT;
	#10
	  clear=0;
	input1=16'b0000100000000000;
	input2=16'b0000000000000000;
	opcode=`RESET;
	#10
	  clear=0;
	input1=16'b0000000000001000;
	input2=16'b0000000000001000;
	opcode=`MULT;
	#10
	  clear=0;
	input1=16'b1111111111111111;
	input2=16'b0000111100001111;
	opcode=`NOOP;
	#10
	  clear=0;
	input1=16'b0000000000001111;
	input2=16'b0000111100001111;
	opcode=`RESET;
	#10
 
	  $stop ;

     end // initial begin
endmodule // TestBench
