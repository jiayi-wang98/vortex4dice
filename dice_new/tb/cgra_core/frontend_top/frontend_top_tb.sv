`timescale 1ns / 1ps
`include "dice_define.vh"

module frontend_top_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int TimeoutCycles = 1000;
  localparam int ClkPeriod = 10;
  
  // =========================================================================
  // Signals
  // =========================================================================
  logic clk;
  logic rst;

  // Interfaces
  cta_dispatch_if dispatch_if();
  cta_complete_if complete_if();
  
  // Memory Buses
  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(48)
  ) metacache_mem_if ();

  VX_mem_bus_if #(
      .DATA_SIZE(VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8),
      .TAG_WIDTH(48)
  ) bitstream_cache_mem_if ();
  
  // CM and PRF
  cgra_cm_if cm0_if();
  cgra_cm_if cm1_if();
  prf_if prf_if();
  
  // Backend Interface
  fdr_if fdr_if();
  
  // Backend Feedback Signals
  logic                       eblock_commit_valid_i;
  logic [EBLOCK_ID_WIDTH-1:0] eblock_commit_id_i;
  block_retire_status_t       brt_info_i;
  logic                       brt_info_write_enable_i;

  int cycle_count;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) $fatal(1, "TIMEOUT");
    end
  end

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  dice_frontend_top u_dut (
      .clk_i                   (clk),
      .rst_i                   (rst),
      .cta_dispatch_if         (dispatch_if),
      .cta_complete_if         (complete_if),
      .metacache_mem_if        (metacache_mem_if),
      .bitstream_cache_mem_if  (bitstream_cache_mem_if),
      .cm0_if                  (cm0_if),
      .cm1_if                  (cm1_if),
      .prf_if                  (prf_if),
      .fdr_if                  (fdr_if),
      .eblock_commit_valid_i   (eblock_commit_valid_i),
      .eblock_commit_id_i      (eblock_commit_id_i),
      .brt_info_i              (brt_info_i),
      .brt_info_write_enable_i (brt_info_write_enable_i)
  );

  // =========================================================================
  // Clock Generation
  // =========================================================================
  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // =========================================================================
  // Helper Tasks
  // =========================================================================
  task automatic reset_dut();
    rst = 1'b1;
    // Dispatch
    dispatch_if.valid = 1'b0;
    dispatch_if.data = '0;
    // Complete (Ready to accept completion)
    complete_if.ready = 1'b1;
    
    // Memory Responses (Always return 0 / invalid)
    metacache_mem_if.req_ready = 1'b1;
    metacache_mem_if.rsp_valid = 1'b0;
    metacache_mem_if.rsp_data = '0;
    
    bitstream_cache_mem_if.req_ready = 1'b1;
    bitstream_cache_mem_if.rsp_valid = 1'b0;
    bitstream_cache_mem_if.rsp_data = '0;
    
    fdr_if.ready = 1'b1; // Ready to accept instructions
    
    // Backend Feedback
    eblock_commit_valid_i = 1'b0;
    eblock_commit_id_i = '0;
    brt_info_i = '0;
    brt_info_write_enable_i = 1'b0;
    
    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask
  
  task automatic dispatch_cta(input dice_pkg::dice_cta_desc_t desc);
    dispatch_if.data = desc;
    dispatch_if.valid = 1'b1;
    @(posedge clk);
    while (dispatch_if.ready !== 1'b1) @(posedge clk);
    dispatch_if.valid = 1'b0;
  endtask

  // =========================================================================
  // Test Stimulus
  // =========================================================================
  initial begin
    dice_pkg::dice_cta_desc_t test_desc;
    
    $display("Frontend Top Level Testbench");
    reset_dut();
    
    $display("TEST 1: Reset Complete");
    assert(fdr_if.valid == 1'b0);
    
    // Test 2: Dispatch a CTA
    $display("TEST 2: Dispatch CTA");
    test_desc = '0;
    test_desc.kernel_desc.start_pc = 32'h1000;
    test_desc.kernel_desc.cta_size.x = 100;
    test_desc.kernel_desc.cta_size.y = 1;
    test_desc.kernel_desc.cta_size.z = 3;

    test_desc.cta_id.y = 13;
    dispatch_cta(test_desc);

    repeat (20) @(posedge clk);
    
    $display("TEST 3: Check Scheduler accepted CTA");
    // We can't peek inside easily without ref, but if dispatch was accepted (task finished), that's good.
    // Also, complete_if.valid shouldn't be high yet.
    assert(complete_if.valid == 1'b0);
    
    $display("ALL TESTS PASSED: frontend_top_tb");
    // `ifdef MODELSIM
        // $stop;
    // `else
        $finish;
    // `endif
  end

// `ifdef VCD
  initial begin
    // $dumpfile("frontend_top_tb.fsdb");
    // $dumpvars(0, frontend_top_tb);
    $fsdbDumpfile("frontend_top_tb.fsdb");
    $fsdbDumpvars("+all");

  end
// `endif

endmodule
