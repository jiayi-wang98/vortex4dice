`ifndef DEIMPORTS
`define DEIMPORTS
`include "dice_define.vh"
package DE_pkg;


parameter int DICE_NUM_REG_BANK = 1024;
parameter int DICE_REG_DATA_WIDTH = 32;
parameter int DICE_NUM_BANKS = 32;
parameter int DICE_NUM_REGS = 32;
parameter int DICE_REG_ADDR_WIDTH = $clog2(DICE_NUM_REG_BANK)-1;
typedef struct packed {
    logic[$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0]  tid;
    logic[$clog2(DICE_NUM_REGS)-1:0] ws;
    logic[DICE_REG_DATA_WIDTH:0] data;
    logic       we;

} reg_wr_cmd;

typedef struct packed {
    logic[$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0] tid;
    logic[$clog2(DICE_NUM_REGS)-1:0] rs;
    logic      re;
} reg_rd_cmd;


function automatic logic [$clog2(DICE_NUM_BANKS)-1:0] bank_select
(
      input logic [$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0] tid
    , input logic [$clog2(DICE_NUM_REGS)-1:0] rs
);
    return (tid[4:0] + rs[4:0]) & 5'h1F;
endfunction

endpackage
`endif
