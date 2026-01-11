// =============================================================================
// Testbench: branch_resolver_tb.sv
// =============================================================================
// Simple testbench for branch_resolver module (sequential FSM).
// Tests:
//   1) Reset - module should be idle
//   2) Uniform branch - sends stack update without divergence
//   3) Conditional branch with unresolved deps - defers to pending table
// =============================================================================

`timescale 1ns / 1ps
`include "dice_define.vh"

module branch_resolver_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // ===========================================================================
  // Parameters
  // ===========================================================================
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 200;
  localparam int PcWidth = DICE_ADDR_WIDTH;
  localparam int ThreadWidth = DICE_NUM_MAX_THREADS_PER_CORE;
  localparam int NumCta = DICE_NUM_MAX_CTA_PER_CORE;
  localparam int NumPredRegs = DICE_PR_NUM;

  // ===========================================================================
  // Clock and Reset
  // ===========================================================================
  logic clk;
  logic rst;

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // ===========================================================================
  // Timeout Counter
  // ===========================================================================
  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      cycle_count <= 0;
    end else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) begin
        $fatal(1, "[%0t] TIMEOUT: Test exceeded %0d cycles", $time, TimeoutCycles);
      end
    end
  end

  // ===========================================================================
  // DUT Signals
  // ===========================================================================
  logic                                          flush_i;
  branch_meta_t                                  branch_metadata_i;
  logic                                          branch_req_valid_i;
  logic [PcWidth-1:0]                            current_pc_i;
  logic [$clog2(NumCta)-1:0]                     hw_cta_id_i;
  thread_mask_t                                  init_thread_mask_i;
  dice_cta_status_t                              cta_status_i;
  logic                                          prf_req_o;
  logic [$clog2(NumCta)+$clog2(NumPredRegs)-1:0] prf_raddr_o;
  logic [ThreadWidth-1:0]                        prf_rdata_i;
  logic                                          update_valid_o;
  logic                                          update_with_divergence_o;
  logic [PcWidth-1:0]                            update_next_pc_o;
  logic [PcWidth-1:0]                            branch_not_taken_pc_o;
  logic [PcWidth-1:0]                            branch_reconvergence_pc_o;
  logic [ThreadWidth-1:0]                        predicate_regs_value_o;
  logic [$clog2(NumCta)-1:0]                     update_hw_cta_id_o;
  logic                                          update_ready_i;
  thread_mask_t                                  real_active_thread_mask_o;
  logic                                          mask_valid_o;
  branch_predict_interface_t                     predict_interface_o;
  logic                                          predict_we_o;
  pending_branch_info_t [NumCta-1:0]             pending_branch_table_o;

  // ===========================================================================
  // DUT Instantiation
  // ===========================================================================
  branch_resolver #(
      .PcWidth    (PcWidth),
      .ThreadWidth(ThreadWidth),
      .NumCta     (NumCta),
      .NumPredRegs(NumPredRegs)
  ) u_dut (
      .clk_i                    (clk),
      .rst_i                    (rst),
      .flush_i                  (flush_i),
      .branch_metadata_i        (branch_metadata_i),
      .branch_req_valid_i       (branch_req_valid_i),
      .current_pc_i             (current_pc_i),
      //.ret_i                    (ret_i),
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

  // ===========================================================================
  // Helper Tasks
  // ===========================================================================
  task automatic reset_dut();
    rst                 = 1'b1;
    flush_i             = 1'b0;
    branch_metadata_i   = '0;
    branch_req_valid_i  = 1'b0;
    current_pc_i        = '0;
    //ret_i               = 1'b0;
    hw_cta_id_i         = '0;
    init_thread_mask_i  = '1;
    cta_status_i        = '0;
    prf_rdata_i         = '0;
    update_ready_i      = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // ===========================================================================
  // Test Stimulus
  // ===========================================================================
  initial begin
    $display("=============================================================");
    $display(" branch_resolver Testbench");
    $display("=============================================================");

    // -------------------------------------------------------------------------
    // TEST 1: Reset - module should be idle
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 1: Reset", $time);
    reset_dut();

    assert (update_valid_o == 1'b0)
    else $fatal(1, "FAIL: update_valid_o should be 0 after reset");
    assert (mask_valid_o == 1'b0)
    else $fatal(1, "FAIL: mask_valid_o should be 0 after reset");
    $display("[%0t] PASS: Reset complete, module idle", $time);

    // -------------------------------------------------------------------------
    // TEST 2: Uniform branch - no divergence
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 2: Uniform branch", $time);

    current_pc_i                           = 32'h0000_1000;
    branch_metadata_i.branch_ena           = 1'b1;
    branch_metadata_i.branch_uni           = 1'b1;  // UNIFORM
    branch_metadata_i.branch_jump_target_offset = 8'd4;
    branch_req_valid_i                     = 1'b1;
    cta_status_i.has_pending_eblock        = 1'b0;
    @(posedge clk);
    branch_req_valid_i                     = 1'b0;

    // Wait for update_valid
    wait (update_valid_o);
    @(posedge clk); // Sample it stable

    assert (update_valid_o == 1'b1)
    else $fatal(1, "FAIL: update_valid_o should be 1 for uniform branch");
    assert (update_with_divergence_o == 1'b0)
    else $fatal(1, "FAIL: update_with_divergence_o should be 0 for uniform");
    $display("[%0t] PASS: Uniform branch handled, no divergence", $time);

    // Let it complete
    repeat (3) @(posedge clk);

    // -------------------------------------------------------------------------
    // TEST 3: Conditional with unresolved deps - defers
    // -------------------------------------------------------------------------
    $display("[%0t] TEST 3: Conditional with pending eblock (defers)", $time);
    reset_dut();

    current_pc_i                           = 32'h0000_2000;
    branch_metadata_i.branch_ena           = 1'b1;
    branch_metadata_i.branch_uni           = 1'b0;  // CONDITIONAL
    branch_metadata_i.branch_jump_target_offset = 8'd8;
    branch_metadata_i.branch_reconv_offset = 8'd16;
    hw_cta_id_i                            = '0;
    cta_status_i.has_pending_eblock        = 1'b1;  // PENDING - can't resolve
    branch_req_valid_i                     = 1'b1;
    @(posedge clk);
    branch_req_valid_i                     = 1'b0;

    // Wait for prediction write
    wait (predict_we_o);


    //repeat (5) @(posedge clk);

    assert (predict_we_o == 1'b1)
    else $fatal(1, "FAIL: predict_we_o should be 1 when deferring");
    assert (predict_interface_o.unresolved_control_divergence == 1'b1)
    else $fatal(1, "FAIL: should set unresolved_control_divergence");
    @(posedge clk);
    $display("[%0t] PASS: Conditional branch deferred", $time);

    // -------------------------------------------------------------------------
    // Done
    // -------------------------------------------------------------------------
    repeat (5) @(posedge clk);
    $display("=============================================================");
    $display(" ALL TESTS PASSED: branch_resolver_tb");
    $display("=============================================================");

`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  // ===========================================================================
  // Waveform Dump
  // ===========================================================================
`ifdef VCD
  initial begin
    $dumpfile("branch_resolver_tb.vcd");
    $dumpvars(0, branch_resolver_tb);
  end
`endif

endmodule
