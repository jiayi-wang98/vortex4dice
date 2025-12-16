`ifndef DEIMPORTS
`define DEIMPORTS
`include "dice_define.vh"
package DE_pkg;


parameter int DICE_NUM_REG_BANK = `DICE_NUM_MAX_THREADS_PER_CORE;
parameter int DICE_DATA_WIDTH = 32;
parameter int DICE_REG_ADDR_WIDTH = $clog2(DICE_NUM_REG_BANK);
typedef struct packed {
    logic[$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0]  tid;
    logic[`DICE_ADDR_WIDTH-1:0] ws;
    logic[`DICE_ADDR_WIDTH-1:0] data;
    logic       we;
    
} reg_wr_cmd;

typedef struct packed {
    logic[$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0] tid;
    logic[`DICE_ADDR_WIDTH-1:0] rs;
    logic      re;
} reg_rd_cmd;

endpackage
`endif