
import dice_pkg::*;
import dice_frontend_pkg::*;



module branch_handler (
    input logic clk,
    input logic rst_n,


    //dispatcher



    //SIMT STACK CONTROLLER
    //handshake
    output logic                                  update_valid,
    input logic                                   update_ready,  
    //Info
    output logic [NUM_STACK*THREAD_WIDTH-1:0]     predicate_regs_value,
    output logic [PC_WIDTH-1:0]                   branch_not_taken_pc,
    output logic [PC_WIDTH-1:0]                   branch_reconvergence_pc,
    //Control Info
    output logic                                  update_with_divergence,
    output logic [PC_WIDTH-1:0]                   update_next_pc,



    //CS and FDR Stage Regs

    //if cta is branch resolving
    input logic                                   scheduled_cta_predicted, 
    input logic [DICE_HW_CTA_ID_WIDTH-1:0]        hw_cta_id_cs,
    input thread_mask_t                           init_thread_mask,

    //CTA Status Table
    output logic [DICE_HW_CTA_ID_WIDTH-1:0]        hw_cta_id_bh,

    output logic                                   unresolved_control_divergence_bh,
    output logic [DICE_ADDR_WIDTH-1:0]             predict_pc_bh, 
    output logic                                   is_return_bh, //prob need this from the decoder

    input logic                                    unresolved_control_divergence_st,
    // input logic                                     

    //decoder / valid checker?
    input branch_meta_t     branch_metadata,
    input logic             ret,     //add if this is included in metadata
    input logic             branch_req_valid,

    output thread_mask_t    real_active_thread_mask,
    output logic            mask_valid //may need to modify this interface (make val/red or smth)


);







    always_comb begin
        // Temporary logic for basic functionality
        real_active_thread_mask = '1; // Default to all threads active
        mask_valid = 1'b1;            // Always valid for now
    end




endmodule














  typedef struct packed {
    logic unresolved_control_divergence;
    logic [DICE_ADDR_WIDTH-1:0] predict_pc;
    logic still_pending_in_BRT;
    logic return_pending;
  } dice_cta_status_t; // CTA status descriptor

  typedef struct packed {
    logic [DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id;
    logic                       unresolved_control_divergence;
    logic [DICE_ADDR_WIDTH-1:0] predict_pc;
    logic is_return;
  } branch_predict_interface_t; // Branch prediction interface descriptor

  typedef struct packed {
    logic [DICE_NUM_MAX_CTA_PER_CORE-1:0] hw_cta_pending;
  } block_retire_status_t; // Block retire status descriptor


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