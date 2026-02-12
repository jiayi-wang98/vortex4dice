/*
FLOW:
- For pending branches in queue, write to status table one cycle after the simt stack handshake
- For current FDR CTA, order doesn't rly matter but follow same flow as queue
- Prioitize queue over FDR CTA
*/

module bh_update_arbiter
 import dice_pkg::*;
 import dice_frontend_pkg::*;
(
    input logic clk_i,
    input logic rst_i,

    // From bh_buffer
    input logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] buff_pred_i,
    input logic                                     buff_valid_i,
    output logic                                    buff_consumed_o,

    // Queue
    input branch_info_t                             bh_fifo_data_out_i,
    input logic                                     bh_fifo_empty_i,
    output logic                                    bh_fifo_pop_o,

    // From current FDR CTA
    input logic pending_wr_to_simt_i,
    input logic pending_wr_to_status_table_i,
    input logic fdr_next_pc_i,
    input logic fdr_cta_id_i,
    input logic fdr_is_return_i,
    input logic fdr_branch_divergence_i,
    output logic pulse_wr_to_simt_o,
    output logic pulse_wr_to_status_table_o,


    // To SIMT Stack`
    output logic stack_update_valid_o,
    output logic stack_update_with_divergence_o,
    output logic [DICE_ADDR_WIDTH-1:0] stack_update_next_pc_o,
    output thread_mask_t stack_predicate_regs_value_o,
    output logic [DICE_ADDR_WIDTH-1:0] stack_branch_not_taken_pc_o,
    output logic [DICE_ADDR_WIDTH-1:0] stack_branch_reconvergence_pc_o,
    input logic update_ready_i,

    // To Status Table
    output logic [2:0] status_table_wr_en_o,
    output logic [DICE_HW_CTA_ID_WIDTH-1:0] status_table_cta_id_o,
    output logic [DICE_ADDR_WIDTH-1:0] status_table_predict_pc_o,
    output logic status_table_unresolved_control_divergence_o,
    output logic status_table_is_return_o

);














endmodule
