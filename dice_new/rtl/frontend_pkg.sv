`timescale 1ns/1ps

/* Intital frontend package:
This will likely need to be changed when i learn more about verilog header files,
I have not researched them yet but am initializing this file for the meta_fetch module
*/


package frontend_pkg;

  // =========================================================
  // PARAMETERS
  // =========================================================
  localparam MAX_NUM_CTA     = 4;
  localparam MAX_NUM_THREADS = 32; 
  localparam PC_WIDTH        = 32;
  
  // Derived Parameters (Calculated automatically)
  localparam CTA_ID_WIDTH    = $clog2(MAX_NUM_CTA);
  localparam MAX_EBLOCK      = MAX_NUM_CTA + 4; 
  localparam EBLOCK_ID_WIDTH = $clog2(MAX_EBLOCK);
  localparam THREAD_WIDTH    = MAX_NUM_THREADS;
  // =========================================================
  // Type definitions
  // =========================================================
  typedef struct packed {
    logic [31:0]     bitstream_addr;     // 32-bit: Address of the CGRA configuration bitstream
    logic [7:0]      bitstream_length;   // 8-bit: Bitstream size in bytes
    logic [1:0]      unrolling_factor;   // 2-bit: Max thread unrolling factor
    logic [7:0]      lat;                // 8-bit: CGRA fabric latency for the p-graph
    logic [33:0]     in_regs;            // 34-bit: Input registers bitmap
    logic [33:0]     out_regs;           // 34-bit: Direct output registers bitmap
    logic [7:0][5:0] ld_dest_regs;       // 8×6-bit: Destination register indexes for memory loads
    logic [2:0]      num_stores;         // 3-bit: Number of stores per thread
    logic [31:0]     branch_meta;        // 32-bit: Branch/Jump metadata
    logic            barrier;            // 1-bit: Barrier indicator (must wait for previous blocks)
    logic            parameter_load;     // 1-bit: True if p-graph only loads constants
  } pgraph_meta_t;


  typedef struct packed {
    logic [CTA_ID_WIDTH-1:0]      schedule_hw_cta_id; //cta id
    logic [PC_WIDTH-1:0]          schedule_next_pc; //pc
    logic [EBLOCK_ID_WIDTH-1:0]   schedule_eblock_id; //e block id
    logic                         schedule_cta_predicted; //prefetch?
    logic [THREAD_WIDTH-1:0]      active_mask;
    dice_kernel_desc_t            kernel_info; //MAY NEED TO BE CHANGED
  } schedule_t; //sched to fdr struct


  typedef struct packed {
    logic [CTA_ID_WIDTH-1:0]      schedule_hw_cta_id; //cta id
    logic [EBLOCK_ID_WIDTH-1:0]   schedule_eblock_id; //e block id
    logic                         schedule_cta_predicted; //prefetch?
    logic [THREAD_WIDTH-1:0]      real_active_mask;
    dice_kernel_desc_t            kernel_info; //MAY NEED TO BE CHANGED
    pgraph_meta_t                 metadata; //may reduce to just vital metadata
    logic                         loaded_buffer;
  } fdr_t; //fdr to ex struct



  
endpackage
