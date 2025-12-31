
module cta_status_table (
    input logic clk,
    input logic rst,

    // From branch handler / branch predictor
    input dice_pkg::branch_predict_interface_t branch_predict_info,
    input logic                    branch_predict_info_write_enable,

    // From Block Retire Table (BRT)
    input dice_pkg::block_retire_status_t brt_info,
    input logic               brt_info_write_enable,

    //from cta controller -> may remove
    input logic clear_entry_valid,
    input logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id,

    // Exposed status for each CTA
    output dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status
);

  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_q;
  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_d;


  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] bp_cta_id;

  always_comb begin
    bp_cta_id = '0;
    for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
      cta_status_d[i] = cta_status_q[i];
    end

    if (brt_info_write_enable) begin
      for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_status_d[i].has_pending_eblock = brt_info.hw_cta_pending[i];
      end
    end

    if (branch_predict_info_write_enable) begin
      bp_cta_id                                = branch_predict_info.hw_cta_id;

      cta_status_d[bp_cta_id].prefetch_cleared = branch_predict_info.unresolved_control_divergence;
      cta_status_d[bp_cta_id].is_return        = branch_predict_info.is_return;
      cta_status_d[bp_cta_id].predict_pc       = branch_predict_info.predict_pc;
      cta_status_d[bp_cta_id].is_barrier       = branch_predict_info.is_barrier;
    end

    if (clear_entry_valid) begin
      cta_status_d[clear_entry_hw_id].has_pending_eblock = 1'b0;
      cta_status_d[clear_entry_hw_id].unresolved_control_divergence = 1'b0;
      cta_status_d[clear_entry_hw_id].is_return = 1'b0;
      cta_status_d[clear_entry_hw_id].predict_pc = '0;
      cta_status_d[clear_entry_hw_id].is_barrier = 1'b0;

    end
  end


  always_ff @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_status_q[i] <= '0;
      end
    end else begin
      for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_status_q[i] <= cta_status_d[i];
      end
    end
  end

  assign cta_status = cta_status_q;

  // `include "dice_assert_defines.vh" - File not found

  `ifndef SYNTHESIS
  // Status is cleared in the next cycle after clear_entry_valid
  always_ff @(posedge clk) begin
    if (clear_entry_valid) begin
      // Check in next cycle
      assert (cta_status_d[clear_entry_hw_id].has_pending_eblock == 0)
      else $error("CleanStatusAfterClear: Status not cleared (check immediate update)");
      // Note: Concurrent assertion |=> checks next cycle. Immediate assertion checks current values.
      // Since cta_status_d is combinatorial from inputs, checking it *during* the cycle it is valid is correct
      // if we want to check the *next* state logic.
      // However, if we want to check the state *after* the clock edge, we need to check cta_status_q in the *next* cycle.
      // But simplifying: checking cta_status_d (next state) is 0 when clear_entry_valid is 1 is equivalent to Checking q is 0 in next cycle.
    end
  end
  `endif

endmodule
