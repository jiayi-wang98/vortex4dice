`timescale 1ns / 1ps
`include "dice_define.vh"

module branch_handler_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int NumStack = dice_frontend_pkg::SIMT_STACK_COUNT;
  localparam int ThreadWidth = dice_frontend_pkg::SIMT_STACK_THREAD_WIDTH;
  localparam int PcWidth = dice_pkg::DICE_ADDR_WIDTH;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic clk;
  logic rst;

  // DUT I/O
  logic update_valid_o;
  logic update_ready_i;
  logic [NumStack*ThreadWidth-1:0] predicate_regs_value_o;
  logic [PcWidth-1:0] branch_not_taken_pc_o;
  logic [PcWidth-1:0] branch_reconvergence_pc_o;
  logic update_with_divergence_o;
  logic [PcWidth-1:0] update_next_pc_o;

  logic scheduled_cta_predicted_i;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] hw_cta_id_cs_i;
  dice_frontend_pkg::thread_mask_t init_thread_mask_i;

  dice_pkg::branch_predict_interface_t branch_predict_interface_o;
  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_table_i;

  dice_frontend_pkg::branch_meta_t branch_metadata_i;
  logic ret_i;
  logic branch_req_valid_i;
  logic [dice_pkg::DICE_ADDR_WIDTH-1:0] current_pc_i;
  dice_frontend_pkg::thread_mask_t real_active_thread_mask_o;

  logic [$clog2(`DICE_PR_NUM * `DICE_NUM_MAX_CTA_PER_CORE)-1:0] prf_raddr_o;
  logic [`DICE_NUM_MAX_THREADS_PER_CORE-1:0] prf_rdata_i;

  logic mask_valid_o;

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  branch_handler #(
      .NumStack   (NumStack),
      .ThreadWidth(ThreadWidth),
      .PcWidth    (PcWidth)
  ) u_dut (
      .clk_i                     (clk),
      .rst_i                     (rst),
      .update_valid_o            (update_valid_o),
      .update_ready_i            (update_ready_i),
      .predicate_regs_value_o    (predicate_regs_value_o),
      .branch_not_taken_pc_o     (branch_not_taken_pc_o),
      .branch_reconvergence_pc_o (branch_reconvergence_pc_o),
      .update_with_divergence_o  (update_with_divergence_o),
      .update_next_pc_o          (update_next_pc_o),
      .scheduled_cta_predicted_i (scheduled_cta_predicted_i),
      .hw_cta_id_cs_i            (hw_cta_id_cs_i),
      .init_thread_mask_i        (init_thread_mask_i),
      .branch_predict_interface_o(branch_predict_interface_o),
      .cta_status_table_i        (cta_status_table_i),
      .branch_metadata_i         (branch_metadata_i),
      .ret_i                     (ret_i),
      .branch_req_valid_i        (branch_req_valid_i),
      .current_pc_i              (current_pc_i),
      .real_active_thread_mask_o (real_active_thread_mask_o),
      .prf_raddr_o               (prf_raddr_o),
      .prf_rdata_i               (prf_rdata_i),
      .mask_valid_o              (mask_valid_o)
  );

  // =========================================================================
  // Clock Generation
  // =========================================================================
  localparam int ClkPeriod = 10;

  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // =========================================================================
  // Reset Sequence
  // =========================================================================
  task automatic apply_reset();
    rst = 1'b1;
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // =========================================================================
  // Test Stimulus
  // =========================================================================
  initial begin
    // Initialize inputs
    update_ready_i            = 1'b1;
    scheduled_cta_predicted_i = 1'b0;
    hw_cta_id_cs_i            = '0;
    init_thread_mask_i        = '1;
    cta_status_table_i        = '0;
    branch_metadata_i         = '0;
    ret_i                     = 1'b0;
    branch_req_valid_i        = 1'b0;
    current_pc_i              = '0;
    prf_rdata_i               = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] branch_handler_tb: Test passed!", $time);
`ifdef MODELSIM
    $stop;
`else
    $finish;
`endif
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("branch_handler_tb.fsdb");
    $fsdbDumpvars(0, branch_handler_tb);
  end
`endif

endmodule
