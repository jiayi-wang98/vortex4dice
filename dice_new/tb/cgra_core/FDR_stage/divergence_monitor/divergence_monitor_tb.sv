// =============================================================================
// Testbench: divergence_monitor_tb.sv (simplified happy-path)
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module divergence_monitor_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 500;
  localparam int NumCta = DICE_NUM_MAX_CTA_PER_CORE;
  localparam int NumPredRegs = DICE_PR_NUM;

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

  dice_cta_status_t [NumCta-1:0]                 cta_status_i;
  pending_branch_info_t [NumCta-1:0]             pending_branch_table_i;
  logic                                          prf_req_o;
  logic [$clog2(NumCta)+$clog2(NumPredRegs)-1:0] prf_raddr_o;
  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0]      prf_rdata_i;
  logic                                          update_valid_o;
  logic                                          update_with_divergence_o;
  logic [DICE_ADDR_WIDTH-1:0]                    update_next_pc_o;
  logic [DICE_ADDR_WIDTH-1:0]                    branch_not_taken_pc_o;
  logic [DICE_ADDR_WIDTH-1:0]                    branch_reconvergence_pc_o;
  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0]      predicate_regs_value_o;
  logic [$clog2(NumCta)-1:0]                     update_hw_cta_id_o;
  logic                                          update_ready_i;
  logic                                          grant_i;
  logic [$clog2(NumCta)-1:0]                     clear_cta_id_o;
  logic                                          clear_divergence_valid_o;

  divergence_monitor #(
      .PcWidth    (DICE_ADDR_WIDTH),
      .ThreadWidth(DICE_NUM_MAX_THREADS_PER_CORE),
      .NumCta     (NumCta),
      .NumPredRegs(NumPredRegs)
  ) u_dut (
      .clk_i                    (clk),
      .rst_i                    (rst),
      .cta_status_i             (cta_status_i),
      .pending_branch_table_i   (pending_branch_table_i),
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
      .grant_i                  (grant_i),
      .clear_cta_id_o           (clear_cta_id_o),
      .clear_divergence_valid_o (clear_divergence_valid_o)
  );

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  task automatic reset_dut();
    rst = 1'b1;
    cta_status_i = '0;
    pending_branch_table_i = '0;
    prf_rdata_i = '0;
    update_ready_i = 1'b1;
    grant_i = 1'b1;
    repeat (5) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  initial begin
    $display("divergence_monitor_tb (happy-path)");

    reset_dut();

    // Set up pending divergence on CTA 0
    cta_status_i[0].unresolved_control_divergence = 1'b1;
    cta_status_i[0].has_pending_eblock = 1'b0;

    pending_branch_table_i[0].pred_reg  = '0;
    pending_branch_table_i[0].neg_pred  = 1'b0;
    pending_branch_table_i[0].taken_pc  = 32'h0000_2000;
    pending_branch_table_i[0].not_taken_pc = 32'h0000_2004;
    pending_branch_table_i[0].reconv_pc = 32'h0000_3000;

    wait (update_valid_o == 1'b1);
    assert (update_hw_cta_id_o == '0)
      else $fatal(1, "update_hw_cta_id_o mismatch");
    assert (update_next_pc_o == pending_branch_table_i[0].taken_pc)
      else $fatal(1, "update_next_pc_o mismatch");

    wait (clear_divergence_valid_o == 1'b1);
    assert (clear_cta_id_o == '0)
      else $fatal(1, "clear_cta_id_o mismatch");

    $display("PASS: divergence resolved");
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

endmodule
