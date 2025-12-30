import dice_pkg::*;

module cta_status_table (
    input logic clk,
    input logic rst,

    // From branch handler / branch predictor
    input branch_predict_interface branch_predict_info,
    input logic                    branch_predict_info_write_enable,

    // From Block Retire Table (BRT)
    input block_retire_status brt_info,
    input logic               brt_info_write_enable,

    //from cta controller -> may remove
    input logic clear_entry_valid,
    input logic [DICE_HW_CTA_ID_WIDTH:0] clear_entry_hw_id,

    // Exposed status for each CTA
    output dice_cta_status_t [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status
);

  dice_cta_status_t cta_status_q[DICE_NUM_MAX_CTA_PER_CORE];
  dice_cta_status_t cta_status_d[DICE_NUM_MAX_CTA_PER_CORE];


  logic [DICE_HW_CTA_ID_WIDTH-1:0] bp_cta_id;

  always_comb begin
    for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
      cta_status_d[i] = cta_status_q[i];
    end

    if (brt_info_write_enable) begin
      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_status_d[i].has_pending_eblock = brt_info.hw_cta_pending[i];
      end
    end

    if (branch_predict_info_write_enable) begin
      bp_cta_id                                = branch_predict_info.hw_cta_id;

      cta_status_d[bp_cta_id].prefetch_cleared = branch_predict_info.prefetch_cleared;
      cta_status_d[bp_cta_id].is_return        = branch_predict_info.is_return;
      cta_status_d[bp_cta_id].predict_pc       = branch_predict_info.predict_pc;
      cta_status_d[bp_cta_id].is_barrier       = branch_predict_info.is_barrier;
    end

    if (clear_entry_valid) begin
      cta_status_d[clear_entry_hw_id] = '0;
    end
  end


  always_ff @(posedge clk) begin
    if (rst) begin
      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_status_q[i] <= '0;
      end
    end else begin
      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_status_q[i] <= cta_status_d[i];
      end
    end
  end

  assign cta_status = cta_status_q;

endmodule
