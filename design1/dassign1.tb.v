//--------------------------------------------------------------------
//		Timescale
//		Means that if you do #1 in the initial block of your
//		testbench, time is advanced by 1ns instead of 1ps
//--------------------------------------------------------------------
`timescale 1ns / 1ps
// Compatibility directive for >0.97a
`default_nettype none
//--------------------------------------------------------------------
//		Design Assign #1, Testbench.
//--------------------------------------------------------------------
module dassign1_tb();
//----------------------------------------------------------------
//		Test Bench Signal Declarations
//----------------------------------------------------------------
   integer i, outfile;
//----------------------------------------------------------------
//		Instantiate modules Module
//----------------------------------------------------------------
dassign1_1	dassign1_1 (y1, nando, a, b, c, d, e);
dassign1_2  dassign1_2 (Ch, Maj, S0, S1,
                   hashiA, hashiB, hashiC, hashiD, hashiE, hashiF, hashiG);
dassign1_3 dassign1_3 (aa, codon);
//----------------------------------------------------------------
//		Design Task #1 Signal Declarations
//----------------------------------------------------------------
   reg  a,b,c,d,e;
   wire [3:0] nando;
   wire y1;


//----------------------------------------------------------------
//		Design Task #2 Signal Declarations
//----------------------------------------------------------------
   wire [31:0] Ch, Maj, S0, S1;
   reg  [31:0] hashiA, hashiB, hashiC, hashiD, hashiE, hashiF, hashiG, hashiH;
   reg  [255:0] hashi[0:15];

//----------------------------------------------------------------
//		Design Task #3 Signal Declarations
//----------------------------------------------------------------
   reg [5:0]  codon;
   wire [4:0] aa;

//----------------------------------------------------------------
//		Test Stimulus
//----------------------------------------------------------------
initial begin
  outfile=$fopen("dassign2.txt");
  if (!outfile) begin
    $display("FAIL WRITE FILE");
    $finish;
  end
   i=0;
   #5;
   while (i<32) begin
      {a,b,c,d,e} = i[4:0];
      #5
      $display(a,b,c,d,e, "\t", y1, "\t", nando);
      i=i+1;
   end //while
   #5
   $readmemh("./hashtable.mem", hashi);
   $monitor(i, "\t", hashiA,hashiB,hashiC,hashiD,hashiE,hashiF,
       "\t", Ch, "\t", Maj, "\t", S0, "\t", S1);
   #5
   for(i=0;i<16;i=i+1) begin
      {hashiA, hashiB, hashiC, hashiD, hashiE, hashiF, hashiG, hashiH} = hashi[i];
      #5
      ;
   end //for 
   #1
   $monitor(codon, "\t", aa);
   #5
   for(i=0;i<64;i=i+1) begin
     codon[5:0] = i[5:0];
     #5
     ;
   end
end // initial begin
endmodule // dassign1_tb
