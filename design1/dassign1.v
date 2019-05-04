// EEM16 - Logic Design
// 2019_04_08
// Design Assignment #1 - Example Solutions
// dassign1.v

module nand2(y,a,b);
   output y;
   input a,b;
   wire d;
   assign d=a&b ;
   assign y=~(d);
endmodule

module dassign1_1 (y, nando[3:0], a, b, c, d, e);
   output y;
   output [3:0] nando;
   input a,b,c,d,e;
   wire y;
   wire [3:0] nando;

/*
 * Note: nando[3:0] are 4 outputs of the NAND gates that is internal to your
 * logic (not including the one that drives the output). You should need only
 * 5 NAND gates in this solution.
 * This allows the autograder to check the internal logic.
 * The ordering/assignment of the output to specific NAND gate does not matter.
 */

 //
 // Your code below
 //
  nand2 nand2_1(nando[0], ~a, b);
  nand2 nand2_2(nando[1], c, ~d);
  nand2 nand2_3(nando[2], nando[0], nando[1]);
  nand2 nand2_4(nando[3], nando[2], e);
  nand2 nand2_5(y, nando[3], nando[3]);
endmodule

module Chm16 (Ch, E, F,G);
  output [31:0] Ch;
  input [31:0] E,F,G;
 //
 // Your code below
 //
  //wire [31:0] E,F,G;
  wire [31:0] T;
  assign T = ~E;
  assign Ch = (E & F) ^ (T & G);
endmodule

//
// Note the 2 different ways to specify the input/output declarations
//
module MAm16 (
  output [31:0] Maj,
  input [31:0] A,B,C
  );
 //
 // Your code below
 //
  assign Maj = (A & B) ^ (A & C) ^ (B & C);
endmodule

module S0m16 (S0, A);
 //
 // Your code below
 //
  output [31:0] S0;
  input [31:0] A;
  assign S0 = {A[1:0],A[31:2]} ^ {A[12:0],A[31:13]} ^ {A[21:0],A[31:22]};
endmodule

module S1m16 (S1, E);
 //
 // Your code below
 //
  output [31:0] S1;
  input [31:0] E;
  assign S1 = {E[5:0],E[31:6]} ^ {E[10:0],E[31:11]} ^ {E[24:0],E[31:25]};
endmodule

module dassign1_2 (Ch, Maj, S0, S1,
                   hashiA, hashiB, hashiC, hashiD, hashiE, hashiF, hashiG);
  output [31:0] Ch, Maj, S0, S1;
  input [31:0] hashiA, hashiB, hashiC, hashiD, hashiE, hashiF, hashiG;
 //
 // Your code below
 //
  Chm16 Ch1(Ch, hashiE, hashiF, hashiG);
  MAm16 MA1(Maj, hashiA, hashiB, hashiC);
  S0m16 S01(S0, hashiA);
  S1m16 S11(S1, hashiE);

endmodule // dassign1_2

module dassign1_3 (aa, codon);
   output [4:0] aa;
   input [5:0] codon;

   localparam NU=2'b00;
   localparam NC=2'b01;
   localparam NA=2'b10;
   localparam NG=2'b11;

   reg [4:0] 	aa;

   always @(codon) begin
  //
  // Your code below
  //
     case(codon)
       {NU,NU,NU}: aa=5'b00000;
       {NU,NU,NC}: aa=5'b00000;
       {NU,NU,NA}: aa=5'b00001;
       {NU,NU,NG}: aa=5'b00001;
       {NU,NC,NU}: aa=5'b00010;
       {NU,NC,NC}: aa=5'b00010;
       {NU,NC,NA}: aa=5'b00010;
       {NU,NC,NG}: aa=5'b00010;
       {NU,NA,NU}: aa=5'b00011;
       {NU,NA,NC}: aa=5'b00011;
       {NU,NA,NG}: aa=5'b00100;
       {NU,NA,NA}: aa=5'b00100;
       {NU,NG,NU}: aa=5'b00101;
       {NU,NG,NC}: aa=5'b00101;
       {NU,NG,NA}: aa=5'b00100;
       {NU,NG,NG}: aa=5'b00110;
       {NC,NU,NU}: aa=5'b00001;
       {NC,NU,NC}: aa=5'b00001;
       {NC,NU,NA}: aa=5'b00001;
       {NC,NU,NG}: aa=5'b00001;
       {NC,NC,NU}: aa=5'b00111;
       {NC,NC,NC}: aa=5'b00111;
       {NC,NC,NA}: aa=5'b00111;
       {NC,NC,NG}: aa=5'b00111;
       {NC,NA,NU}: aa=5'b01000;
       {NC,NA,NC}: aa=5'b01000;
       {NC,NA,NG}: aa=5'b01001;
       {NC,NA,NA}: aa=5'b01001;
       {NC,NG,NU}: aa=5'b01010;
       {NC,NG,NC}: aa=5'b01010;
       {NC,NG,NG}: aa=5'b01010;
       {NC,NG,NA}: aa=5'b01010;
       {NA,NU,NU}: aa=5'b01011;
       {NA,NU,NC}: aa=5'b01011;
       {NA,NU,NA}: aa=5'b01011;
       {NA,NU,NG}: aa=5'b01100;
       {NA,NC,NU}: aa=5'b01101;
       {NA,NC,NC}: aa=5'b01101;
       {NA,NC,NG}: aa=5'b01101;
       {NA,NC,NA}: aa=5'b01101;
       {NA,NA,NU}: aa=5'b01110;
       {NA,NA,NC}: aa=5'b01110;
       {NA,NA,NG}: aa=5'b01111;
       {NA,NA,NA}: aa=5'b01111;
       {NA,NG,NU}: aa=5'b00010;
       {NA,NG,NC}: aa=5'b00010;
       {NA,NG,NG}: aa=5'b01010;
       {NA,NG,NA}: aa=5'b01010;
       {NG,NU,NU}: aa=5'b10000;
       {NG,NU,NC}: aa=5'b10000;
       {NG,NU,NG}: aa=5'b10000;
       {NG,NU,NA}: aa=5'b10000;
       {NG,NC,NU}: aa=5'b10001;
       {NG,NC,NC}: aa=5'b10001;
       {NG,NC,NG}: aa=5'b10001;
       {NG,NC,NA}: aa=5'b10001;
       {NG,NA,NU}: aa=5'b10010;
       {NG,NA,NC}: aa=5'b10010;
       {NG,NA,NG}: aa=5'b10011;
       {NG,NA,NA}: aa=5'b10011;
       {NG,NG,NU}: aa=5'b10100;
       {NG,NG,NC}: aa=5'b10100;
       {NG,NG,NG}: aa=5'b10100;
       {NG,NG,NA}: aa=5'b10100;
     endcase
   end //always

endmodule // dassign1_3
