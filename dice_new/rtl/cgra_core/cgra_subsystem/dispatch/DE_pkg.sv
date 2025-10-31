`ifndef DEIMPORTS
`define DEIMPORTS
`include "dice_pkg.sv"
import dice_pkg::*;
package DE_pkg;
typedef struct packed {
    logic[DICE_TID_WIDTH-1:0]  tid;
    logic[DICE_ADDR_WIDTH-1:0] reg;
    logic[DICE_ADDR_WIDTH-1:0] data;
    logic       we;
    
} reg_wr_cmd;

typedef struct packed {
    logic[DICE_TID_WIDTH-1:0] tid;
    logic[DICE_ADDR_WIDTH-1:0] reg;
    logic      re;
} reg_rd_cmd;

endpackage
`endif