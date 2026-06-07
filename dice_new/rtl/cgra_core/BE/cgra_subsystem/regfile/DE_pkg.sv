`ifndef DEIMPORTS
`define DEIMPORTS
`include "dice_define.vh"
package DE_pkg;


parameter int DICE_NUM_REG_BANK = 512;
parameter int DICE_REG_DATA_WIDTH = 32;
parameter int CACHE_LINE_SIZE = 32;
parameter int NUMBER_OF_MAX_COALESCED_COMMANDS = CACHE_LINE_SIZE/4;
parameter int TID_BITMAP_WIDTH = NUMBER_OF_MAX_COALESCED_COMMANDS;
parameter int BASE_ADDRESS_OFFSET = $clog2(CACHE_LINE_SIZE);
parameter int DICE_NUM_BANKS = 32;
parameter int DICE_NUM_REGS = 32;
parameter int DICE_REG_ADDR_WIDTH = $clog2(DICE_NUM_REG_BANK)-1;
// =========================================================
// Dispatcher architecture constants
// =========================================================
parameter int NUM_SCOREBOARDS  = 4;
parameter int NUM_LANES        = 4;
parameter int CHUNK_SIZE       = `DICE_NUM_MAX_THREADS_PER_CORE / NUM_SCOREBOARDS;
parameter int CHUNK_ADDR_WIDTH = (NUM_SCOREBOARDS == 1) ? 1 : $clog2(NUM_SCOREBOARDS);
parameter int LANE_SIZE        = CHUNK_SIZE / NUM_LANES;
parameter int LANE_WIDTH       = $clog2(LANE_SIZE);

// =========================================================
// Backend integration constants (ported from Mini_Dice DE_pkg for the
// flattened backend glue: dice_brt, credit converters, mem-port helpers).
// NOTE: dice_new keeps its own 32-bit / 32-bank RF definitions above; these are
// additive only and must not redefine existing symbols.
// =========================================================
parameter int NUM_MEM_PORTS             = `DICE_CGRA_MEM_PORTS;
parameter int DICE_NUM_CONST            = `DICE_CR_NUM;
parameter int DICE_NUM_PRED             = `DICE_PR_NUM;
// Total architectural registers (GPR banks + const + pred). Used by the CGRA RF
// launch/writeback bitmaps in the Mini_Dice glue.
parameter int DICE_TOTAL_REGS           = DICE_NUM_REGS + DICE_NUM_CONST + DICE_NUM_PRED;
// In-flight memory accounting for the block-retire table (dice_brt).
parameter int NUM_CREDITS               = `DICE_NUM_MAX_THREADS_PER_CORE * NUM_MEM_PORTS;
parameter int PENDING_MEM_COUNT_WIDTH   = $clog2(NUM_CREDITS + 1);
parameter int MEM_REQ_BUNDLE_FIFO_DEPTH = NUM_MEM_PORTS + 1;
// Width of the e-block (retirement table) id carried alongside an LDST
// writeback so the commit/retire logic can decrement the right block's pending
// count when a per-bank writeback FIFO pops. Mirrors Mini_Dice DE_pkg::EBLOCK_ID_W
// and is numerically identical to dice_pkg::DICE_EBLOCK_ID_WIDTH.
localparam int EBLOCK_ID_W = $clog2(`DICE_NUM_RETIRE_TABLE_ENTRIES + 4);
// TODO(integration): dice_new defines DICE_REG_ADDR_WIDTH = $clog2(512)-1 = 8,
// whereas the Mini_Dice glue assumed $clog2(DICE_TOTAL_REGS). The gen_mem_port_*
// helpers below use the existing dice_new DICE_REG_ADDR_WIDTH; revisit if the
// CGRA ld_dest_reg encoding needs the narrower width.
typedef struct packed {
    logic [$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0]  outcmd_base_tid;
    logic [TID_BITMAP_WIDTH-1:0]                        outcmd_tid_bitmap;
    logic [DICE_REG_ADDR_WIDTH-1:0]                     outcmd_ld_dest_reg;
    logic [NUMBER_OF_MAX_COALESCED_COMMANDS-1:0]
          [BASE_ADDRESS_OFFSET-1:0]                     outcmd_address_map;
    logic [(CACHE_LINE_SIZE*8)-1:0]                     core_rsp_data;
    // Additive: e-block id tagged by the LDST unit on the writeback so the
    // retire/commit path can attribute the pop. Existing producers that leave
    // this unset will read 0 (the existing 1-way sim path ignores retire).
    logic [EBLOCK_ID_W-1:0]                             e_block_id;
} cache_wr_cmd;

typedef struct packed {
    // all banks
    logic [(DICE_REG_DATA_WIDTH*DICE_NUM_BANKS)-1:0] data;
    logic [DICE_NUM_BANKS-1:0] mask;
    logic [($clog2(`DICE_NUM_MAX_THREADS_PER_CORE)*DICE_NUM_BANKS)-1:0] tid;
    // Additive: per-bank e-block id (broadcast of cache_wr_cmd.e_block_id).
    logic [(EBLOCK_ID_W*DICE_NUM_BANKS)-1:0] e_block_id;
} ldst_wr_cmd;

typedef struct packed {
    // single bank
    logic [DICE_REG_DATA_WIDTH-1:0] data;
    logic mask;
    logic [$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0] tid;
    // Additive: e-block id carried through the per-bank LDST writeback FIFO.
    logic [EBLOCK_ID_W-1:0] e_block_id;
} reg_wr_cmd;


function automatic reg_wr_cmd [DICE_NUM_BANKS-1:0] unpack_ldsr_wr
(
    input ldst_wr_cmd cmd
); 
    reg_wr_cmd [DICE_NUM_BANKS-1:0] wr_cmd;
    for (int i = 0; i < DICE_NUM_BANKS; i++) begin
        wr_cmd[i].data = cmd.data[i*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH];
        wr_cmd[i].mask = cmd.mask[i];
        wr_cmd[i].tid = cmd.tid[i];
        wr_cmd[i].e_block_id = cmd.e_block_id[i*EBLOCK_ID_W +: EBLOCK_ID_W];
    end
    return wr_cmd;
endfunction


function automatic ldst_wr_cmd assemble_ldst_wr
(
    input cache_wr_cmd cmd
);
    ldst_wr_cmd wr_data;
    for (int i = 0; i < NUMBER_OF_MAX_COALESCED_COMMANDS; i++) begin
        if (cmd.outcmd_tid_bitmap[i]) begin
            wr_data.data[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]
                = cmd.core_rsp_data[i*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH];
            wr_data.mask[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)] = 1'b1;
            wr_data.tid[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)] = cmd.outcmd_base_tid + cmd.outcmd_address_map[i];
            // Broadcast the writeback's e-block id to every bank it touches.
            wr_data.e_block_id[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)*EBLOCK_ID_W +: EBLOCK_ID_W] = cmd.e_block_id;
        end else begin
            wr_data.data[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH] = '0;
            wr_data.mask[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)] = 1'b0;
            wr_data.tid[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)] = '0;
            wr_data.e_block_id[bank_select(cmd.outcmd_base_tid + cmd.outcmd_address_map[i], cmd.outcmd_ld_dest_reg)*EBLOCK_ID_W +: EBLOCK_ID_W] = '0;
        end
    end
    return wr_data;
endfunction

// Build the returning-thread bitmap for a coalesced load response — i.e. the
// scoreboard release for a whole coalesced line in ONE cycle. Mirrors
// assemble_ldst_wr's per-word thread index: coalesced word i belongs to thread
// (base_tid + address_map[i]). Replaces the serial per-thread response expander:
// every returning thread of the line is released combinationally in one cycle.
function automatic logic [`DICE_NUM_MAX_THREADS_PER_CORE-1:0] gen_wb_tid_bitmap
(
    input logic [$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0]                    base_tid,
    input logic [TID_BITMAP_WIDTH-1:0]                                         tid_bitmap,
    input logic [NUMBER_OF_MAX_COALESCED_COMMANDS-1:0][BASE_ADDRESS_OFFSET-1:0] address_map
);
    logic [`DICE_NUM_MAX_THREADS_PER_CORE-1:0] bm;
    bm = '0;
    for (int i = 0; i < NUMBER_OF_MAX_COALESCED_COMMANDS; i++) begin
        if (tid_bitmap[i]) begin
            bm[base_tid + address_map[i]] = 1'b1;
        end
    end
    return bm;
endfunction

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

// Circular left shift of bitmap by tid[log2(NUM_BANKS)-1:0]
// Used to align read/write bitmaps based on thread ID
function automatic logic [DICE_NUM_BANKS-1:0] shift_bitmap
(
      input logic [DICE_NUM_BANKS-1:0] bitmap
    , input logic [$clog2(`DICE_NUM_MAX_THREADS_PER_CORE)-1:0] tid
);
    logic [$clog2(DICE_NUM_BANKS)-1:0] shift_amt;
    shift_amt = tid[$clog2(DICE_NUM_BANKS)-1:0];
    return (bitmap << shift_amt) | (bitmap >> (DICE_NUM_BANKS[$clog2(DICE_NUM_BANKS)-1:0] - shift_amt));
endfunction

// =========================================================
// Memory-port helpers (ported from Mini_Dice DE_pkg).
// Translate an e-block's {ld_dest_regs, num_stores} metadata into per-port
// valid/op/load-count vectors. ld_dest_reg == 31 is the "no load" sentinel.
// =========================================================
function automatic logic [NUM_MEM_PORTS-1:0] gen_mem_port_valid
(
    input logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] ld_dest_regs,
    input logic [$clog2(NUM_MEM_PORTS+1)-1:0]                num_stores
);
    logic [NUM_MEM_PORTS-1:0] valid_vec;
    valid_vec = '0;
    for (int i = 0; i < NUM_MEM_PORTS; i++) begin
        valid_vec[i] = (i < num_stores) || (ld_dest_regs[i] != DICE_REG_ADDR_WIDTH'(31));
    end
    return valid_vec;
endfunction

function automatic logic [NUM_MEM_PORTS-1:0] gen_mem_port_op
(
    input logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] ld_dest_regs,
    input logic [$clog2(NUM_MEM_PORTS+1)-1:0]                num_stores
);
    logic [NUM_MEM_PORTS-1:0] op_vec;
    op_vec = '0;
    for (int i = 0; i < NUM_MEM_PORTS; i++) begin
        op_vec[i] = (i < num_stores);
    end
    return op_vec;
endfunction

function automatic logic [$clog2(NUM_MEM_PORTS+1)-1:0] gen_num_loads
(
    input logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] ld_dest_regs,
    input logic [$clog2(NUM_MEM_PORTS+1)-1:0]                num_stores
);
    logic [$clog2(NUM_MEM_PORTS+1)-1:0] load_cnt;
    logic [NUM_MEM_PORTS-1:0] valid_vec;
    logic [NUM_MEM_PORTS-1:0] op_vec;
    load_cnt  = '0;
    valid_vec = gen_mem_port_valid(ld_dest_regs, num_stores);
    op_vec    = gen_mem_port_op(ld_dest_regs, num_stores);
    for (int i = 0; i < NUM_MEM_PORTS; i++) begin
        load_cnt += valid_vec[i] & ~op_vec[i];
    end
    return load_cnt;
endfunction

endpackage
`endif
