// EEM16 - Logic Design
// 2019_04_08
// Design Assignment #1 - Example Solutions
// dassign1.v
module top_module(led, sw);
    output [4:0] led;
    input [5:0] sw;
    dassign1_3 d13(led, sw);
endmodule

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
