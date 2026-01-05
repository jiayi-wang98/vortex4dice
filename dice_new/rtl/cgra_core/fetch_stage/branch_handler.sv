// //depending on our style guide the defines will need to be replaced with parameters

// `include "dice_define.vh"

// module branch_handler #(
//     parameter int NumStack    = dice_frontend_pkg::SIMT_STACK_COUNT,
//     parameter int ThreadWidth = dice_frontend_pkg::SIMT_STACK_THREAD_WIDTH,
//     parameter int PcWidth     = dice_pkg::DICE_ADDR_WIDTH
// ) (
//     input logic clk_i,
//     input logic rst_i,

//     // ===================================
//     // SIMT Stack Controller Interface
//     // ===================================
//     output logic                            update_valid_o,
//     input  logic                            update_ready_i,
//     // Update Info
//     output logic [NumStack*ThreadWidth-1:0] predicate_regs_value_o,
//     output logic [             PcWidth-1:0] branch_not_taken_pc_o,
//     output logic [             PcWidth-1:0] branch_reconvergence_pc_o,
//     // Control Info
//     output logic                            update_with_divergence_o,
//     output logic [             PcWidth-1:0] update_next_pc_o,

//     // ===================================
//     // FDR Stage Interfaces
//     // ===================================
//     input logic scheduled_cta_predicted_i,
//     input logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id_cs_i,
//     input dice_frontend_pkg::thread_mask_t init_thread_mask_i,

//     // ===================================
//     // CTA Status Table Interface
//     // ===================================
//     output dice_pkg::branch_predict_interface_t branch_predict_interface_o,
//     input dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_table_i,

//     // ===================================
//     // Decoder Interface
//     // ===================================
//     input dice_frontend_pkg::branch_meta_t branch_metadata_i,
//     input logic ret_i,
//     input logic branch_req_valid_i,
//     input logic [dice_pkg::DICE_ADDR_WIDTH-1:0] current_pc_i,
//     output dice_frontend_pkg::thread_mask_t real_active_thread_mask_o,

//     // ===================================
//     // Predicate Register File Interface -- UNSURE WHAT THIS WILL BE FOR NOW
//     // ===================================
//     output logic [$clog2(`DICE_PR_NUM * `DICE_NUM_MAX_CTA_PER_CORE)-1:0] prf_raddr_o,
//     input  logic [                   `DICE_NUM_MAX_THREADS_PER_CORE-1:0] prf_rdata_i,

//     // ===================================
//     // Valid Check Interface
//     // ===================================
//     output logic mask_valid_o
// );

//   // =========================================================================
//   // Internal Signals & Types
//   // =========================================================================
//   localparam int MetadataLength = 1;
//   localparam int PcInc = 4;

//   logic dependency_resolved;
//   logic is_branch_op;
//   logic is_universal;
//   logic is_conditional;

//   // Jump Targets
//   logic [PcWidth-1:0] jump_target_pc;
//   logic [PcWidth-1:0] reconv_target_pc;
//   logic [PcWidth-1:0] fallthrough_pc;

//   // Background Monitor State
//   logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] monitor_ptr_q;
//   logic monitor_found_work;
//   logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] monitor_work_id;

//   // Arbitration (Foreground vs Background)
//   // 0 = Foreground (Current FDR eblock), 1 = Background (Resolution)
//   logic grant_background;

//   // =========================================================================
//   // Foreground Logic (Current Request from Decoder)
//   // =========================================================================

//   assign is_branch_op = branch_req_valid_i && branch_metadata_i.branch_ena;
//   assign is_universal = is_branch_op && branch_metadata_i.branch_uni;
//   assign is_conditional = is_branch_op && !branch_metadata_i.branch_uni;

//   // Calculate Targets
//   assign fallthrough_pc = current_pc_i + PcInc;
//   assign jump_target_pc = current_pc_i + (32'(branch_metadata_i.branch_jump_target_offset) * PcInc);
//   assign reconv_target_pc = current_pc_i + (32'(branch_metadata_i.branch_reconv_offset) * PcInc);

//   // Dependency Check
//   assign dependency_resolved = (!cta_status_table_i[hw_cta_id_cs_i].has_pending_eblock);

//   // =========================================================================
//   // Arbitration & Stack Update Control
//   // =========================================================================

//   logic fg_can_resolve;
//   assign fg_can_resolve = is_universal || (is_conditional && dependency_resolved);

//   logic fg_req_stack;
//   assign fg_req_stack = is_branch_op && fg_can_resolve;

//   // Background work detection
//   always_comb begin
//     monitor_found_work = 1'b0;
//     monitor_work_id    = '0;

//     monitor_work_id = monitor_ptr_q;
//     if (cta_status_table_i[monitor_ptr_q].unresolved_control_divergence &&
//             !cta_status_table_i[monitor_ptr_q].has_pending_eblock) begin
//       monitor_found_work = 1'b1;
//     end
//   end

//   // Arbitration
//   assign grant_background = monitor_found_work && (!fg_req_stack || !branch_req_valid_i);

//   // =========================================================================
//   // Predicate Register Read
//   // =========================================================================
//   logic [$clog2(`DICE_PR_NUM)-1:0] pr_idx;
//   logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] pr_cta;

//   // Pending branch info storage
//   typedef struct packed {
//     logic [$clog2(`DICE_PR_NUM)-1:0] pred_reg;
//     logic                            neg_pred;
//     logic [PcWidth-1:0]              taken_pc;
//     logic [PcWidth-1:0]              not_taken_pc;
//     logic [PcWidth-1:0]              reconv_pc;
//   } pending_branch_info_t;

//   pending_branch_info_t pending_branch_table_q[dice_pkg::DICE_NUM_MAX_CTA_PER_CORE];

//   always_comb begin
//     pr_cta = '0;
//     pr_idx = '0;

//     if (grant_background) begin
//       pr_cta = monitor_work_id;
//       pr_idx = pending_branch_table_q[monitor_work_id].pred_reg;
//     end else begin
//       pr_cta = hw_cta_id_cs_i;
//       pr_idx = branch_metadata_i.branch_pred_reg;
//     end
//     prf_raddr_o = {pr_cta, pr_idx};
//   end

//   // =========================================================================
//   // SIMT Stack Update Signals
//   // =========================================================================
//   always_comb begin
//     // Default assignments
//     update_valid_o            = 1'b0;
//     update_with_divergence_o  = 1'b0;
//     update_next_pc_o          = '0;
//     branch_not_taken_pc_o     = '0;
//     branch_reconvergence_pc_o = '0;
//     predicate_regs_value_o    = '0;
//     hw_cta_id_bh_o            = '0;

//     // Background Update
//     if (grant_background) begin
//       hw_cta_id_bh_o = monitor_work_id;

//       if (update_ready_i) begin
//         update_valid_o = 1'b1;
//         update_with_divergence_o = 1'b1;

//         predicate_regs_value_o[ThreadWidth-1:0] =
//                     pending_branch_table_q[monitor_work_id].neg_pred ? ~prf_rdata_i : prf_rdata_i;

//         update_next_pc_o = pending_branch_table_q[monitor_work_id].taken_pc;
//         branch_not_taken_pc_o = pending_branch_table_q[monitor_work_id].not_taken_pc;
//         branch_reconvergence_pc_o = pending_branch_table_q[monitor_work_id].reconv_pc;
//       end
//     end  // Foreground Update (Only if resolved immediately)
//     else if (fg_req_stack) begin
//       hw_cta_id_bh_o = hw_cta_id_cs_i;
//       if (update_ready_i) begin
//         update_valid_o = 1'b1;
//         if (is_universal) begin
//           update_with_divergence_o = 1'b0;
//           update_next_pc_o = jump_target_pc;
//         end else begin
//           // Resolved Conditional
//           update_with_divergence_o = 1'b1;
//           predicate_regs_value_o[ThreadWidth-1:0] =
//                          branch_metadata_i.branch_neg_pred ? ~prf_rdata_i : prf_rdata_i;
//           update_next_pc_o = jump_target_pc;
//           branch_not_taken_pc_o = fallthrough_pc;
//           branch_reconvergence_pc_o = reconv_target_pc;
//         end
//       end
//     end
//   end

//   // =========================================================================
//   // Outputs to Status Table / Decoder
//   // =========================================================================
//   always_comb begin
//     unresolved_control_divergence_bh_o = 1'b0;
//     predict_pc_bh_o                    = '0;
//     is_return_bh_o                     = ret_i;

//     if (grant_background) begin
//       // Clearing divergence
//       unresolved_control_divergence_bh_o = 1'b0;
//     end else if (is_conditional && !dependency_resolved) begin
//       // Predicting
//       unresolved_control_divergence_bh_o = 1'b1;
//       predict_pc_bh_o = fallthrough_pc;
//     end
//   end

//   // Real Active Mask to Buffer
//   always_comb begin
//     mask_valid_o              = 1'b1;
//     real_active_thread_mask_o = init_thread_mask_i;

//     if (fg_req_stack && !update_ready_i) begin
//       mask_valid_o = 1'b0;
//     end
//   end

//   // =========================================================================
//   // State Updates (Background Monitor & Pending Table)
//   // =========================================================================
//   always_ff @(posedge clk_i) begin
//     if (rst_i) begin
//       monitor_ptr_q <= '0;
//       for (int unsigned i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
//         pending_branch_table_q[i] <= '0;
//       end
//     end else begin
//       // Advance Monitor
//       monitor_ptr_q <= monitor_ptr_q + 1'b1;

//       // Store Pending Info
//       if (is_conditional && !dependency_resolved && branch_req_valid_i) begin
//         pending_branch_table_q[hw_cta_id_cs_i].pred_reg     <= branch_metadata_i.branch_pred_reg;
//         pending_branch_table_q[hw_cta_id_cs_i].neg_pred     <= branch_metadata_i.branch_neg_pred;
//         pending_branch_table_q[hw_cta_id_cs_i].taken_pc     <= jump_target_pc;
//         pending_branch_table_q[hw_cta_id_cs_i].not_taken_pc <= fallthrough_pc;
//         pending_branch_table_q[hw_cta_id_cs_i].reconv_pc    <= reconv_target_pc;
//       end
//     end
//   end

// endmodule
