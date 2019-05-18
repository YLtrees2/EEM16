// ECEM16 - Logic Design
// 2019_04_11
// Design Assignment #2 - Template
// dassign2.v

module dassign2_1 (
       output [255:0] H256_out,
       output out_v,
       input [255:0] H256_in,
       input [511:0] M_in,
       input in_v,
       input clk
       );
//
// keep track of which round the loop is running
//
reg [6:0] round;

//
// a-h_in are loaded with the input
//
wire [31:0] a_in = H256_in[255:224], b_in = H256_in[223:192];
wire [31:0] c_in = H256_in[191:160], d_in = H256_in[159:128];
wire [31:0] e_in = H256_in[127:96], f_in = H256_in[95:64];
wire [31:0] g_in = H256_in[63:32], h_in = H256_in[31:0];

//
// a-h_q are storage register outputs
// a-h_d are storage register inputs
//
reg [31:0] a_q, b_q, c_q, d_q, e_q, f_q, g_q, h_q;
wire [31:0] a_d, b_d, c_d, d_d, e_d, f_d, g_d, h_d;

wire [255:0] H256_q = {a_q, b_q, c_q, d_q, e_q, f_q, h_q};

// 
// Outputs of the functions that are provided in sha256.v
//
wire [31:0] Ch, Maj, S0, S1;
wire [31:0] W, K;

//
// Note: you need to instantiate the ones not shown here below
//
W_machine Wm16(W, M_in, in_v, clk);
K_machine Km16(K, in_v, clk);

//
// Outputs for the hash engine
//
assign H256_out = {a_in + a_q, b_in + b_q, c_in + c_q, d_in + d_q,
  e_in + e_q, f_in + f_q, g_in + g_q, h_in + h_q};
assign out_v = (round == 64);

//
// Your work here
//

//
// Bank of Registers
//
always @(posedge clk)
begin
  if (in_v) begin
    a_q <= a_in; b_q <= b_in; c_q <= c_in; d_q <= d_in;
    e_q <= e_in; f_q <= f_in; g_q <= g_in; h_q <= h_in;
    round <= 0;
  end else begin
    a_q <= a_d; b_q <= b_d; c_q <= c_d; d_q <= d_d;
    e_q <= e_d; f_q <= f_d; g_q <= g_d; h_q <= h_d;
    round <= round + 1;
  end
end
endmodule

module dassign2_2 (
   output [2:0] heading,
   input [2:0] blked,
   input 	rst, clk
   );

   //
   // Parameters declaration
   //
   parameter STATE_BITS = 3;
   //parameter WAITN = 3'b000;
   //parameter WAITE = 3'b001;
   //parameter WAITW = 3'b011;
   //parameter HEADN = 3'b100;
   //parameter HEADE = 3'b101;
   //parameter HEADW = 3'b111;
   parameter FACEN = 3'b000;
   parameter FACEE = 3'b001;
   parameter FACEW = 3'b010;

   reg [STATE_BITS-1:0] state, nx_state;
   reg [2:0] heading;

   //
   // State registers
   //
   always @(posedge clk) begin
     state <= nx_state;
   end

   //
   // Your work here for the combination logic that calculates the next state and outputs
   //
   always @(*) begin
     if(rst) begin
       nx_state=FACEN;
       heading=3'b000;
     end
     else begin
     case(state) 
       FACEN: 
         case(blked)
           3'b000,3'b001,3'b100,3'b101: begin
             nx_state=FACEN;
             heading=3'b010;
           end
           3'b010,3'b011: begin
             nx_state=FACEW;
             heading=3'b100;
           end
           3'b110: begin
             nx_state=FACEE;
             heading=3'b001;
           end
           3'b111: begin
             nx_state=FACEN;
             heading=3'b000;
           end
         endcase
       FACEW:
         case(blked)
           3'b000,3'b010,3'b100,3'b110:begin
             nx_state=FACEN;
             heading=3'b001;
           end
           3'b001,3'b101:begin
             nx_state=FACEW;
             heading=3'b010;
           end
           3'b011,3'b111:begin
             nx_state=FACEW;
             heading=3'b000;
           end
         endcase
       FACEE:
         case(blked)
           3'b000,3'b001,3'b010,3'b011:begin
             nx_state=FACEN;
             heading=3'b100;
           end
           3'b100,3'b101:begin
             nx_state=FACEE;
             heading=3'b010;
           end
           3'b110,3'b111:begin
             nx_state=FACEE;
             heading=3'b000;
           end
         endcase
     endcase
     end
   end
   //
endmodule // dassign2_2
