`timescale 1ns / 1ps

/* 
 * Definition: X is 1, O is 0
 */
`define X_TILE 1'b1
`define O_TILE 1'b0

/* 
 * Optional: (you may use if you want)
 * Game states 
 */
`define GAME_ST_START	4'b0000
`define GAME_ST_TURN_X 	4'b0001
`define GAME_ST_ERR_X 	4'b0010
`define GAME_ST_CHKV_X 	4'b0011
`define GAME_ST_CHKW_X 	4'b0100
`define GAME_ST_WIN_X 	4'b0101
`define GAME_ST_TURN_O 	4'b0110
`define GAME_ST_ERR_O 	4'b0111
`define GAME_ST_CHKV_O 	4'b1000
`define GAME_ST_CHKW_O 	4'b1001
`define GAME_ST_WIN_O 	4'b1010
`define GAME_ST_CATS 	4'b1011

  /* The grid looks like this:
   * 8 | 7 | 6
   * --|---|---
   * 5 | 4 | 3
   * --|---|---
   * 2 | 1 | 0
   */

  /* 
   * Winning combinations (treys) are the following:
   * 852, 741, 630, 876, 543, 210, 840, 642
   */
  
  /* Suggestions
   * Create a module to check for a validity of a move
   * Create modules to check for a victory in the treys
   */

module top_module(led, clk, sw, btnC, btnU, btnD, btnR, JA, seg, an);
    output [15:0] led;
    input clk;
    input [15:0] sw;
    input btnC, btnU, btnD, btnR;
    output [7:0] JA;
    output [6:0] seg;
    output [3:0] an;

assign an = 0;
    //output [3:0] an;
    //output dp;
    wire [8:0] occ_square, occ_player;
  wire [8:0] occ_pos, occ_square_wire, occ_player_wire;
    //TODO: assign Chaliepixel LEDs
    wire [7:0] game_st_ascii;
    //TODO: assign game_st_ascii to regs
    
    wire flash_clk;
  //reg [7:0] JA_reg;
  //assign JA=JA_reg;

    clock_div clock_Div(
    .clk(clk),
    .rst(btnR),
    .speed(28'd5000000),
    .new_clk(flash_clk)
    );

assign led[8:0]=occ_square[8:0];
//assign seg[6:0]=7'b1100111;
  tictactoe ttt(led[15], led[14], occ_pos, occ_square, occ_player, game_st_ascii, btnC, clk, flash_clk, sw[8:0], btnU, btnD, JA[7:0],seg[6:0]);


  
endmodule


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




module tictactoe(turnX, turnO, occ_pos, occ_square, occ_player, game_st_ascii, reset, clk, flash_clk, sel_pos, buttonX, buttonO,JA, seg);
  output turnX;
  output turnO;
  output [8:0] occ_pos, occ_square, occ_player;
  output [7:0] game_st_ascii;
  //output [2:0] result;

  input reset, clk, flash_clk;
  input [8:0] sel_pos;
  input buttonX, buttonO;

output [7:0] JA;
output [6:0] seg;
  /* 
   * occ_square states if there's a tile in this square or not 
   * occ_player states which type of tile is in the square 
   * game_state is the 4 bit curent state;
   * occ_pos is the board with flashing 
   */
  reg [8:0] occ_square;
  reg [8:0] occ_player;
  reg [3:0] game_state;
  wire [8:0] occ_pos;
  wire [3:0] nx_game_state;

  /*
   * Registers
   *  -- game_state register is provided to get you started
   */ 

  reg [7:0] ascii_reg=8'b01101110;
  reg [3:0] nx_game_state_reg;
  reg [8:0] nx_occ_player;
  reg [8:0] nx_occ_square;
  reg [7:0] nx_ascii;
  wire [8:0] occ_square_wire;
  wire [8:0] occ_player_wire;
  wire [8:0] occ_O_wire;
  wire valid;
  wire winX;
  wire winO;
  wire cat;
  wire check_square;
  wire check_player;
  wire check_O;
  reg [1:0] half_flash_reg=2'b00;
  wire [8:0] win_positions;
  wire [8:0] occ_pos_psudo;
  reg [8:0] occ_pos_reg;
  reg last_buttonX;
  reg last_buttonO;
  reg last_last_buttonX;
  reg last_last_buttonO;
  reg buttonX_reg;
  reg buttonO_reg;
  reg [6:0] seg_reg;

  `define ASCII_X 8'b01011000
  `define ASCII_O 8'b01001111
  `define ASCII_C 8'b01000011
  `define ASCII_E 8'b01000101
  `define ASCII_NONE 8'b01101110
  
  always @(posedge clk) begin
    game_state <= nx_game_state;
    occ_player <= nx_occ_player;
    occ_square <= nx_occ_square;
    ascii_reg <= nx_ascii;
    last_last_buttonX <=(last_last_buttonX|buttonX)&(~buttonO);
    last_last_buttonO <=last_buttonO;
    last_buttonX <= buttonX;
    last_buttonO <= buttonO;
  end
  
  always @(posedge flash_clk) begin
    half_flash_reg <= half_flash_reg + 1'b1;
  end
 
  assign nx_game_state=nx_game_state_reg;
  assign game_st_ascii=ascii_reg;
  assign occ_square_wire=occ_square;
  assign occ_player_wire=occ_player;
  assign occ_O_wire=occ_square&(~occ_player);
  
  assign turnX=(~game_state[3]&~game_state[2]&~game_state[1]&game_state[0])|(~game_state[3]&~game_state[2]&game_state[1]&~game_state[0]);
  assign turnO=(~game_state[3]&game_state[2]&game_state[1]);

  
  assign win_positions[8]=(occ_player[8]&occ_player[5]&occ_player[2])|(occ_player[8]&occ_player[7]&occ_player[6])|(occ_player[8]&occ_player[4]&occ_player[0])|(occ_O_wire[8]&occ_O_wire[5]&occ_O_wire[2])|(occ_O_wire[8]&occ_O_wire[7]&occ_O_wire[6])|(occ_O_wire[8]&occ_O_wire[4]&occ_O_wire[0]);
  assign win_positions[7]=(occ_player[7]&occ_player[4]&occ_player[1])|(occ_player[8]&occ_player[7]&occ_player[6])|(occ_O_wire[7]&occ_O_wire[4]&occ_O_wire[1])|(occ_O_wire[8]&occ_O_wire[7]&occ_O_wire[6]);
  assign win_positions[6]=(occ_player[6]&occ_player[3]&occ_player[0])|(occ_player[8]&occ_player[7]&occ_player[6])|(occ_player[6]&occ_player[4]&occ_player[2])|(occ_O_wire[6]&occ_O_wire[3]&occ_O_wire[0])|(occ_O_wire[8]&occ_O_wire[7]&occ_O_wire[6])|(occ_O_wire[6]&occ_O_wire[4]&occ_O_wire[2]);
  assign win_positions[5]=(occ_player[8]&occ_player[5]&occ_player[2])|(occ_player[5]&occ_player[4]&occ_player[3])|(occ_O_wire[8]&occ_O_wire[5]&occ_O_wire[2])|(occ_O_wire[5]&occ_O_wire[4]&occ_O_wire[3]);
  assign win_positions[4]=(occ_player[7]&occ_player[4]&occ_player[1])|(occ_player[5]&occ_player[4]&occ_player[3])|(occ_player[8]&occ_player[4]&occ_player[0])|(occ_player[6]&occ_player[4]&occ_player[2])|(occ_O_wire[7]&occ_O_wire[4]&occ_O_wire[1])|(occ_O_wire[5]&occ_O_wire[4]&occ_O_wire[3])|(occ_O_wire[8]&occ_O_wire[4]&occ_O_wire[0])|(occ_O_wire[6]&occ_O_wire[4]&occ_O_wire[2]);
  assign win_positions[3]=(occ_player[6]&occ_player[3]&occ_player[0])|(occ_player[5]&occ_player[4]&occ_player[3])|(occ_O_wire[6]&occ_O_wire[3]&occ_O_wire[0])|(occ_O_wire[5]&occ_O_wire[4]&occ_O_wire[3]);
  assign win_positions[2]=(occ_player[8]&occ_player[5]&occ_player[2])|(occ_player[2]&occ_player[1]&occ_player[0])|(occ_player[6]&occ_player[4]&occ_player[2])|(occ_O_wire[8]&occ_O_wire[5]&occ_O_wire[2])|(occ_O_wire[2]&occ_O_wire[1]&occ_O_wire[0])|(occ_O_wire[6]&occ_O_wire[4]&occ_O_wire[2]);
  assign win_positions[1]=(occ_player[7]&occ_player[4]&occ_player[1])|(occ_player[2]&occ_player[1]&occ_player[0])|(occ_O_wire[7]&occ_O_wire[4]&occ_O_wire[1])|(occ_O_wire[2]&occ_O_wire[1]&occ_O_wire[0]);
  assign win_positions[0]=(occ_player[6]&occ_player[3]&occ_player[0])|(occ_player[2]&occ_player[1]&occ_player[0])|(occ_player[8]&occ_player[4]&occ_player[0])|(occ_O_wire[6]&occ_O_wire[3]&occ_O_wire[0])|(occ_O_wire[2]&occ_O_wire[1]&occ_O_wire[0])|(occ_O_wire[8]&occ_O_wire[4]&occ_O_wire[0]);
  
  assign occ_pos[0]=(~win_positions[0]&occ_square[0]&occ_player[0])|(~win_positions[0]&occ_square[0]&occ_O_wire[0]&half_flash_reg[0])|(win_positions[0]&half_flash_reg[1]);
  assign occ_pos[1]=(~win_positions[1]&occ_square[1]&occ_player[1])|(~win_positions[1]&occ_square[1]&occ_O_wire[1]&half_flash_reg[0])|(win_positions[1]&half_flash_reg[1]);
  assign occ_pos[2]=(~win_positions[2]&occ_square[2]&occ_player[2])|(~win_positions[2]&occ_square[2]&occ_O_wire[2]&half_flash_reg[0])|(win_positions[2]&half_flash_reg[1]);
  assign occ_pos[3]=(~win_positions[3]&occ_square[3]&occ_player[3])|(~win_positions[3]&occ_square[3]&occ_O_wire[3]&half_flash_reg[0])|(win_positions[3]&half_flash_reg[1]);
  assign occ_pos[4]=(~win_positions[4]&occ_square[4]&occ_player[4])|(~win_positions[4]&occ_square[4]&occ_O_wire[4]&half_flash_reg[0])|(win_positions[4]&half_flash_reg[1]);
  assign occ_pos[5]=(~win_positions[5]&occ_square[5]&occ_player[5])|(~win_positions[5]&occ_square[5]&occ_O_wire[5]&half_flash_reg[0])|(win_positions[5]&half_flash_reg[1]);
  assign occ_pos[6]=(~win_positions[6]&occ_square[6]&occ_player[6])|(~win_positions[6]&occ_square[6]&occ_O_wire[6]&half_flash_reg[0])|(win_positions[6]&half_flash_reg[1]);
  assign occ_pos[7]=(~win_positions[7]&occ_square[7]&occ_player[7])|(~win_positions[7]&occ_square[7]&occ_O_wire[7]&half_flash_reg[0])|(win_positions[7]&half_flash_reg[1]);
  assign occ_pos[8]=(~win_positions[8]&occ_square[8]&occ_player[8])|(~win_positions[8]&occ_square[8]&occ_O_wire[8]&half_flash_reg[0])|(win_positions[8]&half_flash_reg[1]);
  
  //wire [3:0] total;
  //assign total = 4'b0001;
  // sel_pos[0]+sel_pos[1]+sel_pos[2]+sel_pos[3]+sel_pos[4]+sel_pos[5]+sel_pos[6]+sel_pos[7]+sel_pos[8];
  
  assign valid = (~((sel_pos[0]&occ_square[0])|(sel_pos[1]&occ_square[1])|(sel_pos[2]&occ_square[2])|(sel_pos[3]&occ_square[3])|(sel_pos[4]&occ_square[4])|(sel_pos[5]&occ_square[5])|(sel_pos[6]&occ_square[6])|(sel_pos[7]&occ_square[7])|(sel_pos[8]&occ_square[8])))&((sel_pos==9'b000000001)|(sel_pos==9'b000000010)|(sel_pos==9'b000000100)|(sel_pos==9'b000001000)|(sel_pos==9'b000010000)|(sel_pos==9'b000100000)|(sel_pos==9'b001000000)|(sel_pos==9'b010000000)|(sel_pos==9'b100000000));
  
  check_row_column_diagonal c_r_c_d1(check_square, occ_square_wire);
  check_row_column_diagonal c_r_c_d2(check_player, occ_player_wire);
  check_row_column_diagonal c_r_c_d3(check_O, occ_O_wire);
  assign winX=check_square&check_player;
  assign winO=check_square&check_O;
  assign cat= ~check_player&(~check_O)&occ_square[0]&occ_square[1]&occ_square[2]&occ_square[3]&occ_square[4]&occ_square[5]&occ_square[6]&occ_square[7]&occ_square[8];
 
  assign seg=seg_reg; 
  
  always @(*) begin
    if(reset) begin
      nx_game_state_reg=`GAME_ST_START;
      nx_occ_player=8'b00000000;
      nx_occ_square=8'b00000000;
      nx_ascii=`ASCII_NONE;
    end
    else begin
      case(game_state)
        `GAME_ST_START:begin
          nx_game_state_reg=`GAME_ST_TURN_X;
          //nx_occ_player=8'b00000000;
          //nx_occ_square=8'b00000000;
          nx_ascii=`ASCII_NONE;
        end
        
        `GAME_ST_TURN_X:begin
          if (~last_buttonO&buttonO) begin
            nx_game_state_reg=`GAME_ST_ERR_X;
            nx_ascii=`ASCII_E;
          end
          if (~last_buttonX&buttonX) begin
            nx_game_state_reg=`GAME_ST_CHKV_X;
            nx_ascii=`ASCII_NONE;
          end
        end
        
        `GAME_ST_ERR_X:begin
          if (~last_buttonX&buttonX) begin
            //if (~last_buttonX&buttonX)begin
              nx_game_state_reg=`GAME_ST_CHKV_X;
              nx_ascii=`ASCII_NONE;
            //end
          end
        end
        
        `GAME_ST_CHKV_X:begin
          if (valid) begin
            nx_game_state_reg=`GAME_ST_CHKW_X;
            nx_ascii=`ASCII_NONE;
            nx_occ_square[0]=sel_pos[0]|occ_square[0];
            nx_occ_square[1]=sel_pos[1]|occ_square[1];
            nx_occ_square[2]=sel_pos[2]|occ_square[2];
            nx_occ_square[3]=sel_pos[3]|occ_square[3];
            nx_occ_square[4]=sel_pos[4]|occ_square[4];
            nx_occ_square[5]=sel_pos[5]|occ_square[5];
            nx_occ_square[6]=sel_pos[6]|occ_square[6];
            nx_occ_square[7]=sel_pos[7]|occ_square[7];
            nx_occ_square[8]=sel_pos[8]|occ_square[8];
            nx_occ_player[0]=sel_pos[0]|occ_player[0];
            nx_occ_player[1]=sel_pos[1]|occ_player[1];
            nx_occ_player[2]=sel_pos[2]|occ_player[2];
            nx_occ_player[3]=sel_pos[3]|occ_player[3];
            nx_occ_player[4]=sel_pos[4]|occ_player[4];
            nx_occ_player[5]=sel_pos[5]|occ_player[5];
            nx_occ_player[6]=sel_pos[6]|occ_player[6];
            nx_occ_player[7]=sel_pos[7]|occ_player[7];
            nx_occ_player[8]=sel_pos[8]|occ_player[8];
          end
          if (~valid)begin
            nx_game_state_reg=`GAME_ST_ERR_X;
            nx_ascii=`ASCII_E;
          end
        end
        
        `GAME_ST_CHKW_X:begin
          if (winX) begin
            nx_game_state_reg=`GAME_ST_WIN_X;
            nx_ascii=`ASCII_X;
          end
          if (cat) begin
            nx_game_state_reg=`GAME_ST_CATS;
            nx_ascii=`ASCII_C;
          end
          if (~cat&(~winX)) begin
            nx_game_state_reg=`GAME_ST_TURN_O;
            nx_ascii=`ASCII_NONE;
          end
        end
        
        `GAME_ST_WIN_X:begin
            nx_game_state_reg=`GAME_ST_WIN_X;
            nx_ascii=`ASCII_X;
            
        end
        
        `GAME_ST_CATS:begin
            nx_game_state_reg=`GAME_ST_CATS;
            nx_ascii=`ASCII_C;
        end
        
        `GAME_ST_TURN_O:begin
          if (~last_buttonX&buttonX) begin
            nx_game_state_reg=`GAME_ST_ERR_O;
            nx_ascii=`ASCII_E;
          end
          if (~last_buttonO&buttonO) begin
            nx_game_state_reg=`GAME_ST_CHKV_O;
            nx_ascii=`ASCII_NONE;
          end
        end
       
        `GAME_ST_ERR_O:begin
          if (~last_buttonO&buttonO) begin
            nx_game_state_reg=`GAME_ST_CHKV_O;
            nx_ascii=`ASCII_NONE;
          end
        end
        
        `GAME_ST_CHKV_O:begin
          if (valid) begin
            nx_game_state_reg=`GAME_ST_CHKW_O;
            nx_ascii=`ASCII_NONE;
            nx_occ_square[0]=sel_pos[0]|occ_square[0];
            nx_occ_square[1]=sel_pos[1]|occ_square[1];
            nx_occ_square[2]=sel_pos[2]|occ_square[2];
            nx_occ_square[3]=sel_pos[3]|occ_square[3];
            nx_occ_square[4]=sel_pos[4]|occ_square[4];
            nx_occ_square[5]=sel_pos[5]|occ_square[5];
            nx_occ_square[6]=sel_pos[6]|occ_square[6];
            nx_occ_square[7]=sel_pos[7]|occ_square[7];
            nx_occ_square[8]=sel_pos[8]|occ_square[8];
          end
          else if (~valid)begin
            nx_game_state_reg=`GAME_ST_ERR_O;
            nx_ascii=`ASCII_E;
          end
        end
        
        `GAME_ST_CHKW_O:begin
          if (winO) begin
            nx_game_state_reg=`GAME_ST_WIN_O;
            nx_ascii=`ASCII_O;
          end
          if (cat) begin
            nx_game_state_reg=`GAME_ST_CATS;
            nx_ascii=`ASCII_C;
          end
          if (~cat&(~winO)) begin
            nx_game_state_reg=`GAME_ST_TURN_X;
            nx_ascii=`ASCII_NONE;
          end
        end
        
        `GAME_ST_WIN_O:begin
            nx_game_state_reg=`GAME_ST_WIN_O;
            nx_ascii=`ASCII_O;
            
        end
        
      endcase
      
      case(nx_ascii)
        `ASCII_X:begin
          seg_reg=7'b1001100;
        end
        `ASCII_O:begin
          seg_reg=7'b0000001;
        end
        `ASCII_NONE:begin
          seg_reg=7'b1101010;
        end
        `ASCII_E:begin
          seg_reg=7'b0110000;
        end
        `ASCII_C:begin
          seg_reg=7'b0110001;
        end
      endcase
      
    end
  end
  
  wire [7:0] JA;
  LED_Driver LED_Driver(clk, reset,occ_O_wire,occ_player_wire, win_positions,JA);
  
endmodule



module check_row_column_diagonal(result, input_wires);
  input [8:0] input_wires;
  output result;
    /* 
   * Winning combinations (treys) are the following:
   * 852, 741, 630, 876, 543, 210, 840, 642
   */
  assign result=(input_wires[8]&input_wires[5]&input_wires[2])|(input_wires[7]&input_wires[4]&input_wires[1])|(input_wires[6]&input_wires[3]&input_wires[0])|(input_wires[8]&input_wires[7]&input_wires[6])|(input_wires[5]&input_wires[4]&input_wires[3])|(input_wires[2]&input_wires[1]&input_wires[0])|(input_wires[8]&input_wires[4]&input_wires[0])|(input_wires[6]&input_wires[4]&input_wires[2]);

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
  reg [5:0] i = 0;

  always @(posedge(clk))begin
    led_array_state2 = 36'b000000000000000000000000000000000000;
    emit=1'b0;
    if (led_array_state[i] == 1'b1) begin
      led_array_state2[i]=1'b1;
      emit=1'b1;
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
    input [8:0] occ_O_wire,
    input [8:0] occ_player,
  input [8:0] win_positions,
    output reg [7:0] JA
    //output reg [15:0] led
    );
    
    wire sm_clk;
    wire tester_clk;

    reg [1:0] counter;
    reg flash_reg=1'b0;
    
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
  wire [35:0] grid_state_wire;
  
  assign grid_state_wire[0]=(occ_player[8]&~win_positions[8])|(flash_reg&win_positions[8]&occ_player[8]);
  assign grid_state_wire[1]=grid_state_wire[0];
  assign grid_state_wire[2]=(occ_player[7]&~win_positions[7])|(flash_reg&win_positions[7]&occ_player[7]);
  assign grid_state_wire[3]=grid_state_wire[2];
  assign grid_state_wire[4]=(occ_player[6]&~win_positions[6])|(flash_reg&win_positions[6]&occ_player[6]);
  assign grid_state_wire[5]=grid_state_wire[4];
  assign grid_state_wire[12]=(occ_player[5]&~win_positions[5])|(flash_reg&win_positions[5]&occ_player[5]);
  assign grid_state_wire[13]=grid_state_wire[12];
  assign grid_state_wire[14]=(occ_player[4]&~win_positions[4])|(flash_reg&win_positions[4]&occ_player[4]);
  assign grid_state_wire[15]=grid_state_wire[14];
  assign grid_state_wire[16]=(occ_player[3]&~win_positions[3])|(flash_reg&win_positions[3]&occ_player[3]);
  assign grid_state_wire[17]=grid_state_wire[16];
  assign grid_state_wire[24]=(occ_player[2]&~win_positions[2])|(flash_reg&win_positions[2]&occ_player[2]);
  assign grid_state_wire[25]=grid_state_wire[24];
  assign grid_state_wire[26]=(occ_player[1]&~win_positions[1])|(flash_reg&win_positions[1]&occ_player[1]);
  assign grid_state_wire[27]=grid_state_wire[26];
  assign grid_state_wire[28]=(occ_player[0]&~win_positions[0])|(flash_reg&win_positions[0]&occ_player[0]);
  assign grid_state_wire[29]=grid_state_wire[28];
  
  assign grid_state_wire[6]=(occ_O_wire[8]&~win_positions[8])|(flash_reg&win_positions[8]&occ_O_wire[8]);
  assign grid_state_wire[7]=grid_state_wire[6];
  assign grid_state_wire[8]=(occ_O_wire[7]&~win_positions[7])|(flash_reg&win_positions[7]&occ_O_wire[7]);
  assign grid_state_wire[9]=grid_state_wire[8];
  assign grid_state_wire[10]=(occ_O_wire[6]&~win_positions[6])|(flash_reg&win_positions[6]&occ_O_wire[6]);
  assign grid_state_wire[11]=grid_state_wire[10];
  assign grid_state_wire[18]=(occ_O_wire[5]&~win_positions[5])|(flash_reg&win_positions[5]&occ_O_wire[5]);
  assign grid_state_wire[19]=grid_state_wire[18];
  assign grid_state_wire[20]=(occ_O_wire[4]&~win_positions[4])|(flash_reg&win_positions[4]&occ_O_wire[4]);
  assign grid_state_wire[21]=grid_state_wire[20];
  assign grid_state_wire[22]=(occ_O_wire[3]&~win_positions[3])|(flash_reg&win_positions[3]&occ_O_wire[3]);
  assign grid_state_wire[23]=grid_state_wire[22];
  assign grid_state_wire[30]=(occ_O_wire[2]&~win_positions[2])|(flash_reg&win_positions[2]&occ_O_wire[2]);
  assign grid_state_wire[31]=grid_state_wire[30];
  assign grid_state_wire[32]=(occ_O_wire[1]&~win_positions[1])|(flash_reg&win_positions[1]&occ_O_wire[1]);
  assign grid_state_wire[33]=grid_state_wire[32];
  assign grid_state_wire[34]=(occ_O_wire[0]&~win_positions[0])|(flash_reg&win_positions[0]&occ_O_wire[0]);
  assign grid_state_wire[35]=grid_state_wire[34];



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
     JA[0] = buffer_en[0] ? buffer_ctrl[0] : 1'bZ;
     JA[1] = buffer_en[1] ? buffer_ctrl[1] : 1'bZ;
     JA[2] = buffer_en[2] ? buffer_ctrl[2] : 1'bZ;
     JA[3] = buffer_en[3] ? buffer_ctrl[3] : 1'bZ;
     JA[4] = buffer_en[4] ? buffer_ctrl[4] : 1'bZ;
     JA[5] = buffer_en[5] ? buffer_ctrl[5] : 1'bZ;
     JA[6] = buffer_en[6] ? buffer_ctrl[6] : 1'bZ;
     JA[7] = 1'bZ;
      
    end
 
  always @(*)begin
    grid_state=grid_state_wire;
  end
    
   
  
    //TESTER BLOCK, DO NOT MODIFY
    
  always @ (posedge(tester_clk))
    begin
      
      flash_reg = flash_reg+1'b1;
        
        //led[1:0] = counter; 
        //counter = counter + 1'b1;
    end

    
endmodule
