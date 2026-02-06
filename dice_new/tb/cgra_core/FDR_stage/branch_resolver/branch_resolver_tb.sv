// =============================================================================
// Testbench: branch_resolver_tb.sv (simplified happy-path)
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module branch_resolver_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 500;
  localparam int NumCta = DICE_NUM_MAX_CTA_PER_CORE;

  logic clk;
  logic rst;

  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  // DUT Signals
  logic                              flush_i;
  branch_meta_t                      branch_metadata_i;
  logic                              branch_req_valid_i;
  logic [DICE_ADDR_WIDTH-1:0]        current_pc_i;
  logic [$clog2(NumCta)-1:0]         hw_cta_id_i;
  thread_mask_t                      init_thread_mask_i;
  dice_cta_status_t                  cta_status_i;
  logic                              prf_req_o;
  logic [$clog2(NumCta)+$clog2(DICE_PR_NUM)-1:0] prf_raddr_o;
  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] prf_rdata_i;
  logic                              update_valid_o;
  logic                              update_with_divergence_o;
  logic [DICE_ADDR_WIDTH-1:0]        update_next_pc_o;
  logic [DICE_ADDR_WIDTH-1:0]        branch_not_taken_pc_o;
  logic [DICE_ADDR_WIDTH-1:0]        branch_reconvergence_pc_o;
  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] predicate_regs_value_o;
  logic [$clog2(NumCta)-1:0]         update_hw_cta_id_o;
  logic                              update_ready_i;
  thread_mask_t                      real_active_thread_mask_o;
  logic                              mask_valid_o;
  branch_predict_interface_t         predict_interface_o;
  logic                              predict_we_o;
  pending_branch_info_t [NumCta-1:0] pending_branch_table_o;

  branch_resolver u_dut (
      .clk_i                    (clk),
      .rst_i                    (rst),
      .flush_i                  (flush_i),
      .branch_metadata_i        (branch_metadata_i),
      .branch_req_valid_i       (branch_req_valid_i),
      .current_pc_i             (current_pc_i),
      .hw_cta_id_i              (hw_cta_id_i),
      .init_thread_mask_i       (init_thread_mask_i),
      .cta_status_i             (cta_status_i),
      .prf_req_o                (prf_req_o),
      .prf_raddr_o              (prf_raddr_o),
      .prf_rdata_i              (prf_rdata_i),
      .update_valid_o           (update_valid_o),
      .update_with_divergence_o (update_with_divergence_o),
      .update_next_pc_o         (update_next_pc_o),
      .branch_not_taken_pc_o    (branch_not_taken_pc_o),
      .branch_reconvergence_pc_o(branch_reconvergence_pc_o),
      .predicate_regs_value_o   (predicate_regs_value_o),
      .update_hw_cta_id_o       (update_hw_cta_id_o),
      .update_ready_i           (update_ready_i),
      .real_active_thread_mask_o(real_active_thread_mask_o),
      .mask_valid_o             (mask_valid_o),
      .predict_interface_o      (predict_interface_o),
      .predict_we_o             (predict_we_o),
      .pending_branch_table_o   (pending_branch_table_o)
  );

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst = 1'b1;
    flush_i = 1'b0;
    branch_metadata_i = '0;
    branch_req_valid_i = 1'b0;
    current_pc_i = '0;
    hw_cta_id_i = '0;
    init_thread_mask_i = '0;
    cta_status_i = '0;
    prf_rdata_i = '0;
    update_ready_i = 1'b1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  initial begin
    logic [DICE_ADDR_WIDTH-1:0] pc;

    $display("branch_resolver_tb (happy-path)");

    reset_dut();

    pc = 32'h0000_1000;
    current_pc_i = pc;
    hw_cta_id_i = '0;
    init_thread_mask_i = {DICE_NUM_MAX_THREADS_PER_CORE{1'b1}};
    cta_status_i.has_pending_eblock = 1'b0;

    branch_metadata_i.branch_ena = 1'b1;
    branch_metadata_i.branch_uni = 1'b1;
    branch_metadata_i.branch_pred_reg = '0;
    branch_metadata_i.branch_neg_pred = 1'b0;
    branch_metadata_i.is_return = 1'b0;
    branch_metadata_i.branch_jump_target_offset = 1;
    branch_metadata_i.branch_reconv_offset = 0;

    branch_req_valid_i = 1'b1;
    @(posedge clk);
    branch_req_valid_i = 1'b0;

    wait (update_valid_o == 1'b1);
    assert (update_with_divergence_o == 1'b0)
      else $fatal(1, "update_with_divergence_o mismatch");
    assert (update_hw_cta_id_o == hw_cta_id_i)
      else $fatal(1, "update_hw_cta_id_o mismatch");
    assert (update_next_pc_o == (pc + DICE_METADATA_WIDTH))
      else $fatal(1, "update_next_pc_o mismatch");

    wait (mask_valid_o == 1'b1);
    assert (real_active_thread_mask_o == init_thread_mask_i)
      else $fatal(1, "real_active_thread_mask_o mismatch");

    $display("PASS: uniform branch resolved");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

endmodule
