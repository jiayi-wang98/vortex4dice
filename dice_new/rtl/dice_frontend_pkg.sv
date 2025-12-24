
`include "dice_define.vh"

package dice_frontend_pkg;

  import dice_pkg::*;

  localparam int DICE_ADDR_WIDTH   = 32;
  localparam int BITSTREAM_LENGTH_WIDTH = 8;
  
  localparam int MAX_EBLOCK      = 8; 
  localparam int EBLOCK_ID_WIDTH = $clog2(MAX_EBLOCK);

  localparam int REG_NUM = `DICE_GPR_NUM + `DICE_PR_NUM + `DICE_CR_NUM;


  // =========================================================
  // Type definitions
  // =========================================================
  
  //metadata
  typedef struct packed {
    logic [DICE_ADDR_WIDTH-1:0]             bitstream_addr;
    logic [BITSTREAM_LENGTH_WIDTH-1:0]      bitstream_length;
    logic [1:0]                             unrolling_factor;
    logic [7:0]                             lat;
    logic [REG_NUM-1:0]                     in_regs_bitmap;
    logic [REG_NUM-1:0]                     out_regs_bitmap;
    logic [$clog2(REG_NUM)-1:0]             ld_dest_regs [$clog2(DICE_CGRA_MEM_PORTS-1):0];
    logic [$clog2(DICE_CGRA_MEM_PORTS-1):0] num_stores;
    branch_meta_t                           branch_meta;
    logic                                   barrier;
    logic                                   parameter_load;
  } pgraph_meta_t;

  //thread mask -> typedef may not be needed
  typedef logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] thread_mask_t;

  typedef struct packed {
    logic [BITSTREAM_LENGTH_WIDTH-1:0]      bitstream_length; //may not need
    logic [REG_NUM-1:0]                     in_regs_bitmap;
    logic [REG_NUM-1:0]                     out_regs_bitmap;
    logic [$clog2(REG_NUM)-1:0]             ld_dest_regs [$clog2(DICE_CGRA_MEM_PORTS-1):0];
    logic [$clog2(DICE_CGRA_MEM_PORTS-1):0] num_stores; 
    logic [1:0]                             unrolling_factor;
    logic [7:0]                             lat;
    logic                                   parameter_load;
    thread_mask_t                           active_mask;
  } fdr_meta_t;     

  //stage borders
  typedef struct packed {
    logic [DICE_HW_CTA_ID_WIDTH-1:0]        schedule_hw_cta_id; 
    logic [DICE_ADDR_WIDTH-1:0]             schedule_next_pc;   
    logic [EBLOCK_ID_WIDTH-1:0]             schedule_eblock_id;
    logic                                   schedule_cta_predicted;
    thread_mask_t                           active_mask;
    dice_kernel_desc_t                      kernel_info;
  } schedule_t;


  typedef struct packed {
    logic [DICE_HW_CTA_ID_WIDTH-1:0]          schedule_hw_cta_id;
    logic [EBLOCK_ID_WIDTH-1:0]               schedule_eblock_id;
    logic                                     schedule_cta_predicted;
    logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] real_active_mask;
    dice_kernel_desc_t                        kernel_info; 
    fdr_meta_t                                metadata; 
    logic                                     loaded_buffer;
  } fdr_t; 

  /**
  * Branch Metadata Structure
  * Defines control logic for p-graph branching, including predicate dependencies,
  * jump targets, and hardware reconvergence points.
  */
  typedef struct packed {
      logic                                 branch_ena;                // Branch enable: active if branch is associated with current p-graph
      logic                                 branch_uni;                // Universal branch: if set, ignore branch_pred_reg
      logic [$clog2(DICE_PR_NUM)-1:0]       branch_pred_reg;           // Predicate register dependency index
      logic                                 branch_neg_pred;           // Polarity: 1 = jump if pred is 0; 0 = jump if pred is 1
      
      // Jump Target Calculation: 
      // Actual PC = Current_PC + (branch_jump_target_offset * Metadata_Length)
      logic [$clog2(DICE_MAX_PGRAPHS)-1:0]  branch_jump_target_offset; 
      
      // Reconvergence Calculation: 
      // Reconvergence PC = Current_PC + (branch_reconv_offset * Metadata_Length)
      logic [$clog2(DICE_MAX_PGRAPHS)-1:0]  branch_reconv_offset;      
  } branch_meta_t;


endpackage

