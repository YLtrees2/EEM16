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


module tictactoe(turnX, turnO, occ_pos, occ_square, occ_player, game_st_ascii, reset, clk, flash_clk, sel_pos, buttonX, buttonO);
  output turnX;
  output turnO;
  output [8:0] occ_pos, occ_square, occ_player;
  output [7:0] game_st_ascii;
  output [2:0] result;

  input reset, clk, flash_clk;
  input [8:0] sel_pos;
  input buttonX, buttonO;

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
  reg flash_reg=1'b0;
  reg [1:0] half_flash_reg=2'b00;
  wire [8:0] win_positions;
  wire [8:0] occ_pos_psudo;
  reg [8:0] occ_pos_reg;
  reg [1:0] nx_half_flash_reg;

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
  end
  
  always @(posedge flash_clk, negedge flash_clk) begin
    flash_reg <= flash_reg + 1'b1;
    half_flash_reg <= half_flash_reg + 1'b1;
  end
 
  assign nx_game_state=nx_game_state_reg;
  assign game_st_ascii=ascii_reg;
  assign occ_square_wire=occ_square;
  assign occ_player_wire=occ_player;
  assign occ_O_wire=occ_square&(~occ_player);
  
  assign turnX=(~game_state[3]&~game_state[2]&~game_state[1]&game_state[0])|(~game_state[3]&~game_state[2]&game_state[1]&~game_state[0]);
  assign turnO=(~game_state[3]&game_state[2]&game_state[1]);
  //TODO: output [8:0] occ_pos;
  //TODO: wire [8:0] occ_pos;
  
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
  
  //assign occ_pos = occ_pos_reg;
  

  assign valid = ~((sel_pos[0]&occ_square[0])|(sel_pos[1]&occ_square[1])|(sel_pos[2]&occ_square[2])|(sel_pos[3]&occ_square[3])|(sel_pos[4]&occ_square[4])|(sel_pos[5]&occ_square[5])|(sel_pos[6]&occ_square[6])|(sel_pos[7]&occ_square[7])|(sel_pos[8]&occ_square[8]));
  
  check_row_column_diagonal c_r_c_d1(check_square, occ_square_wire);
  check_row_column_diagonal c_r_c_d2(check_player, occ_player_wire);
  check_row_column_diagonal c_r_c_d3(check_O, occ_O_wire);
  assign winX=check_square&check_player;
  assign winO=check_square&check_O;
  assign cat= ~check_player&(~check_O)&occ_square[0]&occ_square[1]&occ_square[2]&occ_square[3]&occ_square[4]&occ_square[5]&occ_square[6]&occ_square[7]&occ_square[8];
  
  
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
          if (buttonO) begin
            nx_game_state_reg=`GAME_ST_ERR_X;
            nx_ascii=`ASCII_E;
          end
          else if (buttonX) begin
            nx_game_state_reg=`GAME_ST_CHKV_X;
            nx_ascii=`ASCII_NONE;
          end
        end
        
        `GAME_ST_ERR_X:begin
          if (buttonX) begin
            nx_game_state_reg=`GAME_ST_CHKV_X;
            nx_ascii=`ASCII_NONE;
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
          else if (~valid)begin
            nx_game_state_reg=`GAME_ST_ERR_X;
            nx_ascii=`ASCII_E;
          end
        end
        
        `GAME_ST_CHKW_X:begin
          if (winX) begin
            nx_game_state_reg=`GAME_ST_WIN_X;
            nx_ascii=`ASCII_X;
          end
          else if (cat) begin
            nx_game_state_reg=`GAME_ST_CATS;
            nx_ascii=`ASCII_C;
          end
          else begin
            nx_game_state_reg=`GAME_ST_TURN_O;
            nx_ascii=`ASCII_NONE;
          end
        end
        
        `GAME_ST_WIN_X:begin
            nx_game_state_reg=`GAME_ST_WIN_X;
            nx_ascii=`ASCII_X;
            //occ_pos_reg=occ_pos_psudo;
        end
        
        `GAME_ST_CATS:begin
            nx_game_state_reg=`GAME_ST_CATS;
            nx_ascii=`ASCII_C;
        end
        
        `GAME_ST_TURN_O:begin
          if (buttonX) begin
            nx_game_state_reg=`GAME_ST_ERR_O;
            nx_ascii=`ASCII_E;
          end
          else if (buttonO) begin
            nx_game_state_reg=`GAME_ST_CHKV_O;
            nx_ascii=`ASCII_NONE;
          end
        end
       
        `GAME_ST_ERR_O:begin
          if (buttonO) begin
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
          else if (cat) begin
            nx_game_state_reg=`GAME_ST_CATS;
            nx_ascii=`ASCII_C;
          end
          else begin
            nx_game_state_reg=`GAME_ST_TURN_X;
            nx_ascii=`ASCII_NONE;
          end
        end
        
        `GAME_ST_WIN_O:begin
            nx_game_state_reg=`GAME_ST_WIN_O;
            nx_ascii=`ASCII_O;
            //occ_pos_reg=occ_pos_psudo;
        end
        
      endcase
    end
  end
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