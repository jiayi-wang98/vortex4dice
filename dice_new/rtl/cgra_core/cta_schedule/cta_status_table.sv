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

    // Exposed status for each CTA
    output cta_status [DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status
);

  // -------------------------------------------------------------------------
  // Local parameters
  // -------------------------------------------------------------------------
  localparam int HW_CTA_ID_WIDTH = DICE_HW_CTA_ID_WIDTH;

  // -------------------------------------------------------------------------
  // Internal storage: CTA status registers
  // -------------------------------------------------------------------------
  cta_status cta_status_q[DICE_NUM_MAX_CTA_PER_CORE];

  // -------------------------------------------------------------------------
  // Synchronous update logic
  // -------------------------------------------------------------------------
  always_ff @(posedge clk) begin
    if (rst) begin
      // Clear all CTA statuses on reset
      for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_status_q[i] <= '0;
      end
    end else begin
      // =============================================================
      // BRT -> CTA status update
      // =============================================================
      // ASSUMPTIONS:
      //  - dice_pkg::block_retire_status has:
      //        logic [DICE_NUM_MAX_CTA_PER_CORE-1:0] hw_cta_pending;
      //
      //  - dice_pkg::cta_status has at least:
      //        logic has_pending_eblock;
      //
      // This makes cta_status_q[i].has_pending_eblock reflect the
      // current BRT hw_cta_pending bit for CTA i.
      if (brt_info_write_enable) begin
        for (int i = 0; i < DICE_NUM_MAX_CTA_PER_CORE; i++) begin
          cta_status_q[i].has_pending_eblock <= brt_info.hw_cta_pending[i];
        end
      end

      // =============================================================
      // Branch handler / predictor -> CTA status update
      // =============================================================
      // ASSUMPTIONS for dice_pkg::branch_predict_interface:
      //   logic [HW_CTA_ID_WIDTH-1:0] hw_cta_id;
      //   logic                       bitstream_loaded;
      //   logic                       prefetch_cleared;   // or similar
      //   logic                       decode_done;
      //   logic                       barrier_met;
      //   thread_mask_t               active_thread_mask; // example type
      //
      // ASSUMPTIONS for dice_pkg::cta_status:
      //   logic                       bitstream_loaded;
      //   logic                       prefetch_cleared;
      //   logic                       decode_done;
      //   logic                       barrier_met;
      //   logic                       has_pending_eblock;  // from BRT
      //   thread_mask_t               active_thread_mask;
      //
      // This block updates *one* CTA entry, indexed by hw_cta_id.
      if (branch_predict_info_write_enable) begin
        logic [HW_CTA_ID_WIDTH-1:0] bp_cta_id;
        bp_cta_id = branch_predict_info.hw_cta_id;

`ifndef SYNTHESIS
        if (bp_cta_id >= DICE_NUM_MAX_CTA_PER_CORE) begin
          $error(
              "branch_predict_info.hw_cta_id (%0d) out of range (DICE_NUM_MAX_CTA_PER_CORE=%0d) at time %0t",
              bp_cta_id, DICE_NUM_MAX_CTA_PER_CORE, $time);
        end
`endif

        if (bp_cta_id < DICE_NUM_MAX_CTA_PER_CORE) begin
          cta_status_q[bp_cta_id].bitstream_loaded   <= branch_predict_info.bitstream_loaded;
          cta_status_q[bp_cta_id].prefetch_cleared   <= branch_predict_info.prefetch_cleared;
          cta_status_q[bp_cta_id].decode_done        <= branch_predict_info.decode_done;
          cta_status_q[bp_cta_id].barrier_met        <= branch_predict_info.barrier_met;
          cta_status_q[bp_cta_id].active_thread_mask <= branch_predict_info.active_thread_mask;
          // NOTE: has_pending_eblock is updated from BRT, so we
          //       intentionally do not touch it here.
        end
      end
    end
  end

  // -------------------------------------------------------------------------
  // Combinational outputs
  // -------------------------------------------------------------------------
  assign cta_status = cta_status_q;

endmodule
