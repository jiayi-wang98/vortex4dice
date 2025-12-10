package frontend_pkg;

  import dice_pkg::*;

  localparam int BITSTREAM_ADDR_WIDTH   = 32;
  localparam int BITSTREAM_LENGTH_WIDTH = 8;
  
  localparam int MAX_EBLOCK      = 8; 
  localparam int EBLOCK_ID_WIDTH = $clog2(MAX_EBLOCK);

  // =========================================================
  // Type definitions
  // =========================================================
  
  typedef struct packed {
    logic [BITSTREAM_ADDR_WIDTH-1:0]   bitstream_addr;
    logic [BITSTREAM_LENGTH_WIDTH-1:0] bitstream_length;
    logic [1:0]                        unrolling_factor;
    logic [7:0]                        lat;
    logic [33:0]                       in_regs;
    logic [33:0]                       out_regs;
    logic [7:0][5:0]                   ld_dest_regs;
    logic [2:0]                        num_stores;
    logic [31:0]                       branch_meta;
    logic                              barrier;
    logic                              parameter_load;
  } pgraph_meta_t;

  // FIXED: Removed backtick ` to use the Package Parameter directly
  typedef logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] thread_mask_t;

  typedef struct packed {
    // Use DICE_HW_CTA_ID_WIDTH directly from dice_pkg
    logic [DICE_HW_CTA_ID_WIDTH-1:0]  schedule_hw_cta_id; 
    
    // Use DICE_ADDR_WIDTH directly from dice_pkg for PC
    logic [DICE_ADDR_WIDTH-1:0]       schedule_next_pc;   
    
    logic [EBLOCK_ID_WIDTH-1:0]       schedule_eblock_id;
    logic                             schedule_cta_predicted;
    thread_mask_t                     active_mask;
    dice_kernel_desc_t                kernel_info;
  } schedule_t;

  typedef struct packed {
    logic [DICE_HW_CTA_ID_WIDTH-1:0]  schedule_hw_cta_id;
    logic [EBLOCK_ID_WIDTH-1:0]       schedule_eblock_id;
    logic                             schedule_cta_predicted;
    logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] real_active_mask;
    dice_kernel_desc_t                kernel_info; 
    pgraph_meta_t                     metadata; 
    logic                             loaded_buffer;
  } fdr_t; 
  
endpackage