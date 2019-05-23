`timescale 1ns / 1ps

module clock_div(
    input clk,
    input rst,
    input [28:0] speed, // = 100MHz/(2*desired_clock_frequency)
    output reg new_clk
    );
 
    // Count value that counts to define_speed
    reg [27:0] count;
    
    // Run on the positive edge of the clk and rst signals
    always @ (posedge(clk),posedge(rst))
    begin
        // When rst is high set count and new_clk to 0
        if (rst == 1'b1)
        begin 
            count = 28'b0;   
            new_clk = 1'b0;            
        end
        // When the count has reached the constant
        // reset count and toggle the output clock
        else if (count == speed)
        begin
            count = 28'b0;
            new_clk = ~new_clk;
        end
        // increment the clock and keep the output clock
        // the same when the constant hasn't been reached        
        else
        begin
            count = count + 1'b1;
            new_clk = new_clk;
        end
    end
endmodule

module Charlieplexer(
   input clk,
   input [35:0] led_array_state,
   output reg [5:0] row,
   output reg [5:0] col,
   output reg emit 
   );
// TODO: write the Charlieplexer state machine (Design Assignment 2)
  reg [35:0] led_array_state2 = 36'b000000000000000000000000000000000000;
  reg i = 0;

  always @(posedge(clk))begin
    led_array_state2 = 36'b000000000000000000000000000000000000;
    if (led_array_state[i] == 1'b1) begin
      led_array_state2[i]=1'b1;
    end
    
    i = i + 1;
    if (i == 36)
      i=0;
  end
  
  always @(*)
begin
  row[0]=led_array_state2[0]|led_array_state2[1]|led_array_state2[2]|led_array_state2[3]|led_array_state2[4]|led_array_state2[5];
  row[1]=led_array_state2[6]|led_array_state2[7]|led_array_state2[8]|led_array_state2[9]|led_array_state2[10]|led_array_state2[11];
  row[2]=led_array_state2[12]|led_array_state2[13]|led_array_state2[14]|led_array_state2[15]|led_array_state2[16]|led_array_state2[17];
  row[3]=led_array_state2[18]|led_array_state2[19]|led_array_state2[20]|led_array_state2[21]|led_array_state2[22]|led_array_state2[23];
  row[4]=led_array_state2[24]|led_array_state2[25]|led_array_state2[26]|led_array_state2[27]|led_array_state2[28]|led_array_state2[29];
  row[5]=led_array_state2[30]|led_array_state2[31]|led_array_state2[32]|led_array_state2[33]|led_array_state2[34]|led_array_state2[35];
  
  col[0]=led_array_state2[0]|led_array_state2[6]|led_array_state2[12]|led_array_state2[18]|led_array_state2[24]|led_array_state2[30];
  col[1]=led_array_state2[1]|led_array_state2[7]|led_array_state2[13]|led_array_state2[19]|led_array_state2[25]|led_array_state2[31];
  col[2]=led_array_state2[2]|led_array_state2[8]|led_array_state2[14]|led_array_state2[20]|led_array_state2[26]|led_array_state2[32];
  col[3]=led_array_state2[3]|led_array_state2[9]|led_array_state2[15]|led_array_state2[21]|led_array_state2[27]|led_array_state2[33];
  col[4]=led_array_state2[4]|led_array_state2[10]|led_array_state2[16]|led_array_state2[22]|led_array_state2[28]|led_array_state2[34];
  col[5]=led_array_state2[5]|led_array_state2[11]|led_array_state2[17]|led_array_state2[23]|led_array_state2[29]|led_array_state2[35];
end


endmodule

module buffer_translator(
    input [5:0] row,
    input [5:0] col,
    input emit,
    output reg [6:0] en,
    output reg [6:0] ctrl
);

// TODO: translate row and col into en and ctrl as described in Design Assignment 2
// Examples:

// Example 1: Light Col 0 in Row 0
//    Inputs:
//       row  [5:0] = 6'b000001
//       col  [5:0] = 6'b000001
//       emit       = 1'b1
//    Outputs:
//       en   [6:0] = 7'b0000011
//       ctrl [6:0] = 7'b0000010


// Example 2: Light no LEDs in Row 0
//    Inputs:
//       row  [5:0] = 6'b000001
//       col  [5:0] = 6'b000001
//       emit       = 1'b0
//    Outputs:
//       en   [6:0] = 7'b0000000
//       ctrl [6:0] = 7'b0000000

// Example 3: Light Col 1 in Row 4
//    Inputs:
//       row  [5:0] = 6'b010000
//       col  [5:0] = 6'b000010
//       emit       = 1'b1
//    Outputs:
//       en   [6:0] = 7'b0010010  
//       ctrl [6:0] = 7'b0000010

// Example 4: Light no LEDs in Row 4
//    Inputs:
//       row  [5:0] = 6'b010000
//       col  [5:0] = 6'b000010
//       emit       = 1'b0
//    Outputs:
//       en   [6:0] = 7'b0000000  
//       ctrl [6:0] = 7'b0000000

// Example 5: Light Col 5 in Row 4
//    Inputs:
//       row  [5:0] = 6'b010000
//       col  [5:0] = 6'b100000
//       emit       = 1'b1
//    Outputs:
//       en   [6:0] = 7'b1010000  
//       ctrl [6:0] = 7'b1000000
  always @(*)
    begin
      en[0]=(row[0]|(col[0]&(row[1]|row[2]|row[3]|row[4]|row[5])))&emit;
      en[1]=((col[0]&row[0])|row[1]|(col[1]&(row[2]|row[3]|row[4]|row[5])))&emit;
      en[2]=((col[1]&(row[0]|row[1]))|row[2]|(col[2]&(row[3]|row[4]|row[5])))&emit;
      en[3]=((col[2]&(row[0]|row[1]|row[2]))|row[3]|(col[3]&(row[4]|row[5])))&emit;
      en[4]=((col[3]&(row[0]|row[1]|row[2]|row[3]))|row[4]|(col[4]&row[5]))&emit;
      en[5]=((col[4]&(row[0]|row[1]|row[2]|row[3]|row[4]))|row[5])&emit;
      en[6]=(col[5]&(row[0]|row[1]|row[2]|row[3]|row[4]|row[5]))&emit;
      
      ctrl[0]=(!row[0])&emit;
      ctrl[1]=(!row[1])&emit;
      ctrl[2]=(!row[2])&emit;
      ctrl[3]=(!row[3])&emit;
      ctrl[4]=(!row[4])&emit;
      ctrl[5]=(!row[5])&emit;
      ctrl[6]=(col[5])&emit;
      
    end
endmodule


module LED_Driver(
    input clk,
    input btnC,
    output reg [7:0] JA,
    output reg [15:0] led
    );
    
    wire sm_clk;
    wire tester_clk;

    reg [1:0] counter;
    
    clock_div clock_Div(
    .clk(clk),
    .rst(btnC),
    .speed(28'd50000000),
    .new_clk(tester_clk)
    );
    
    clock_div clock_Div2(
    .clk(clk),
    .rst(btnC),
    .speed(28'd2500),
    .new_clk(sm_clk)
    );
      
    reg [35:0] grid_state; //1 for LED's that are on (5:0 is row 0 LEDs 5:0, etc.)
    
    wire [5:0] arr_row; //addressing wires
    wire [5:0] arr_col;
    wire led_emit; //LED emit control signal

    wire [6:0] buffer_en;  //tristate buffer control signals
    wire [6:0] buffer_ctrl;
   
    Charlieplexer Charlie(
    .clk(sm_clk),
    .led_array_state(grid_state),
    .row(arr_row),
    .col(arr_col),
    .emit(led_emit)
    );

    buffer_translator BT(
    .row(arr_row),
    .col(arr_col),
    .emit(led_emit),
    .en(buffer_en),
    .ctrl(buffer_ctrl)
    );

    always @ (*)
    begin
       //TODO: Use buffer_en and buffer_ctrl to drive JA[7:0] 
       
// Example 1: Light Col 0 in Row 0
//    Inputs:
//       en   [6:0] =  7'b0000011
//       ctrl [6:0] =  7'b0000010
//    Outputs:
//       JA   [7:0] = 8'bZZZZZZ10

// Example 2: Light no LEDs in Row 0
//    Inputs:
//       en   [6:0] =  7'b0000000
//       ctrl [6:0] =  7'b0000000
//    Outputs:
//       JA   [7:0] = 8'bZZZZZZZZ

// Example 3: Light Col 1 in Row 4
//    Inputs:
//       en   [6:0] =  7'b0010010  
//       ctrl [6:0] =  7'b0000010
//    Outputs:
//       JA   [7:0] = 8'bZZZ0ZZ1Z

// Example 4: Light no LEDs in Row 4
//    Inputs:
//       en   [6:0] =  7'b0000000  
//       ctrl [6:0] =  7'b0000000
//    Outputs:
//       JA   [7:0] = 8'bZZZZZZZZ

// Example 5: Light Col 5 in Row 4
//    Inputs:
//       en   [6:0] =  7'b1010000  
//       ctrl [6:0] =  7'b1000000
//    Outputs:
//       JA   [7:0] = 8'bZ1Z0ZZZZ
      JA[0] = buffer_en[0] ? buffer_ctrl[0] : 1'bZ;
      JA[1] = buffer_en[1] ? buffer_ctrl[1] : 1'bZ;
      JA[2] = buffer_en[2] ? buffer_ctrl[2] : 1'bZ;
      JA[3] = buffer_en[3] ? buffer_ctrl[3] : 1'bZ;
      JA[4] = buffer_en[4] ? buffer_ctrl[4] : 1'bZ;
      JA[5] = buffer_en[5] ? buffer_ctrl[5] : 1'bZ;
      JA[6] = buffer_en[6] ? buffer_ctrl[6] : 1'bZ;
      JA[7] = 1'bZ;
      
    end
 
    //TESTER BLOCK, DO NOT MODIFY
    always @ (posedge(tester_clk))
    begin
        case (counter)
             2'b00:
             begin
                grid_state = 36'b000000_000111_000001_000011_000001_000111;
             end
             2'b01:
             begin
                grid_state = 36'b000000_111000_001000_011000_001000_111000;
             end
             2'b10:
             begin
                grid_state = 36'b000000_111111_100101_111111_101101_111111;
             end
             2'b11:
             begin
                grid_state = 36'b000000_001100_010010_100001_000000_010010;
             end
        endcase
        
        led[1:0] = counter; 
        counter = counter + 1'b1;
    end

    
endmodule
