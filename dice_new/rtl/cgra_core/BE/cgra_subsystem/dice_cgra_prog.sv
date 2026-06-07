// =============================================================================
// dice_cgra_prog — CGRA bitstream programming (extracted from dice_core).
//
// Streams the two config-memory chunk buses (cm0/cm1, flattened from the FDR's
// cgra_cm_if) into the CGRA bitstream serial buffer, and drives the resulting
// scanchain (prog_rst/done/we/din) to the CGRA fabric (dice_top, in dice_cgra_rf).
//
// The single-cycle program pulse (prog_v_i) and the target bank
// (prog_pending_buffer_i) are produced by dice_eblock_tracker, which owns the
// prog-pending FSM state. This module owns only the serial buffer + cm wiring.
// =============================================================================
module dice_cgra_prog
  import dice_pkg::*;
#(
    // Number of config-memory chunks per bitstream — must match the FDR's
    // cgra_cm_if CHUNK_COUNT (same formula).
    parameter int CM_CHUNK_COUNT = (DICE_BITSTREAM_SIZE + DICE_MEM_DATA_WIDTH - 1)
                                   / DICE_MEM_DATA_WIDTH
)(
    input  logic clk_i,
    input  logic rst_i,

    // Config-memory chunk streams from the FDR (flattened cm0_if/cm1_if).
    input  logic [DICE_MEM_DATA_WIDTH-1:0] cm0_data_i,
    input  logic [CM_CHUNK_COUNT-1:0]      cm0_chunk_en_i,
    input  logic [DICE_MEM_DATA_WIDTH-1:0] cm1_data_i,
    input  logic [CM_CHUNK_COUNT-1:0]      cm1_chunk_en_i,

    // Single-cycle program pulse + target bank (from dice_eblock_tracker).
    input  logic prog_v_i,
    input  logic prog_pending_buffer_i,

    // Status back to the tracker / RF-fabric wrapper.
    output logic prog_busy_o,
    output logic prog_ready_o,

    // Scanchain drive to the CGRA fabric (dice_top, in dice_cgra_rf).
    output logic prog_rst_o,
    output logic prog_done_o,
    output logic prog_we_o,
    output logic prog_din_o
);

  // Buffer status outputs not currently consumed outside (observability TODO).
  logic       prog_active_lo;
  logic       prog_active_bank_lo;
  logic [1:0] cm_bank_valid_lo;
  logic [15:0] bsload_cnt_lo;

  cgra_bitstream_buf_serial #(
      .PROG_BITSTREAM_BITS_P(DICE_BITSTREAM_SIZE)
  ) u_cgra_bitstream_buf_serial (
      .clk_i(clk_i),
      .reset_i(rst_i),
      .cm0_data_i(cm0_data_i),
      .cm0_chunk_en_i(cm0_chunk_en_i),
      .cm1_data_i(cm1_data_i),
      .cm1_chunk_en_i(cm1_chunk_en_i),
      .v_i(prog_v_i),
      .bank_i(prog_pending_buffer_i),
      .ready_o(prog_ready_o),
      .busy_o(prog_busy_o),
      .prog_active_o(prog_active_lo),
      .prog_active_bank_o(prog_active_bank_lo),
      .bank_valid_o(cm_bank_valid_lo),
      .prog_rst_o(prog_rst_o),
      .prog_done_o(prog_done_o),
      .prog_we_o(prog_we_o),
      .prog_din_o(prog_din_o),
      .bsload_cnt_o(bsload_cnt_lo)
  );

endmodule
