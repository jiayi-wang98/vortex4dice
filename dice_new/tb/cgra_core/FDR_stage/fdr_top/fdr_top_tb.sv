`timescale 1ns / 1ps
`include "VX_define.vh"

module fdr_top_tb;
  import dice_pkg::*;
  import dice_frontend_pkg::*;

  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int TagWidth = 48;
  localparam int BitstreamSize = 2056;
  localparam int ChunkSize = VX_gpu_pkg::VX_MEM_DATA_WIDTH;
  localparam int NumChunks = (BitstreamSize + ChunkSize - 1) / ChunkSize;
  localparam int ClkPeriod = 10;
  localparam int TimeoutCycles = 10000;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                                                 clk;
  logic                                                                 rst;

  // DUT I/O
  logic                                                                 clear_prefetch_valid_o;
  logic                       [     dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_prefetch_hw_cta_id_o;
  logic                                                                 predict_miss_flush_o;

  logic                       [                          ChunkSize-1:0] cm0_data_o;
  logic                       [                          NumChunks-1:0] cm0_chunk_en_o;
  logic                       [                          ChunkSize-1:0] cm1_data_o;
  logic                       [                          NumChunks-1:0] cm1_chunk_en_o;

  // Cache bus interfaces
  VX_mem_bus_if #(
      .DATA_SIZE(ChunkSize / 8),
      .TAG_WIDTH(TagWidth)
  ) metacache_mem_if ();

  VX_mem_bus_if #(
      .DATA_SIZE(ChunkSize / 8),
      .TAG_WIDTH(TagWidth)
  ) bitstream_cache_mem_if ();

  // Scheduler/FDR interfaces (Slave side in DUT, Master here)
  cta_sched_if schedule_if ();
  fdr_if fdr_if ();
  simt_stack_status_if simt_status_if();
  dice_bh_simt_if simt_stack_update(); // Master from DUT
  branch_handler_if status_table_bh_if(); // Master from DUT
  
  // NEW: Missing interfaces
  prf_if prf_if(); // Master from DUT
  branch_handler_if bh_if(); // Master from DUT (Wait, status_table_bh_if IS bh_if?? No.)
  // fdr_top has:
  // branch_handler_if.master bh_if,
  
  cgra_cm_if cm0_if();
  cgra_cm_if cm1_if();
  
  
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
  fdr_top #(
      .TAG_WIDTH     (TagWidth),
      .BITSTREAM_SIZE(BitstreamSize)
  ) u_dut (
      .clk_i                     (clk),
      .rst_i                     (rst),
      .metacache_mem_if          (metacache_mem_if),
      .bitstream_cache_mem_if    (bitstream_cache_mem_if),
      .schedule_if               (schedule_if),
      .fdr_if                    (fdr_if),
      .simt_status_if            (simt_status_if),
      .simt_stack_update_if      (simt_stack_update), // Corrected name simt_stack_update_if
      .prf_if                    (prf_if),
      .bh_if                     (bh_if), // Corrected assignment
      .cm0_if                    (cm0_if),
      .cm1_if                    (cm1_if)
  );
  
  // Wait, I originally mapped status_table_bh_if to ??? fdr_top has bh_if.
  // And fdr_top also deals with pending branches?
  // No, fdr_top DOES NOT have status_table_bh_if??
  // Let's check fdr_top ports again.
  // 31:     branch_handler_if.master bh_if,
  // That's it.
  // My previous TB had `branch_handler_if status_table_bh_if();` but mapped it to what?
  // Ah, I mapped it to `status_table_bh_if` in u_dut? But u_dut ports didn't match.

  // =========================================================================
  // Clock Generation
  // =========================================================================
  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // =========================================================================
  // Reset Sequence
  // =========================================================================
  task automatic apply_reset();
    rst = 1'b1;
    
    // Initialize interface signals driving DUT Inputs
    
    // Scheduler Interface (Master here driving Slave DUT)
    schedule_if.valid = 1'b0;
    schedule_if.data = '0;
    
    // FDR Interface (DUT is Master)
    fdr_if.ready = 1'b1; 
    
    // SIMT Status (Slave DUT) 
    simt_status_if.status = '0;
    
    // SIMT Update (Master DUT)
    simt_stack_update.update_ready = 1'b1;
    
    // PRF Interface (Master DUT)
    prf_if.rsp_data = '0; // TB provides read data
    // prf_if.rsp_ready? No, DUT is master of req, TB is slave.
    // prf_if.req_valid (from DUT).
    // prf_if.rsp_ready (from DUT).
    
    // BH Interface (Master DUT)
    // DUT writes to BH. `bh_if.bh_data` (output from DUT). `write_enable` (output).
    // So TB inputs these. No drivers needed.
    
    // CM If (Master DUT)
    // DUT drives data/en. TB observes.
    
    // Cache buses (Slave here responding to DUT Master)
    metacache_mem_if.req_ready = 1'b1;
    metacache_mem_if.rsp_valid = 1'b0;
    metacache_mem_if.rsp_data = '0;
    
    bitstream_cache_mem_if.req_ready = 1'b1;
    bitstream_cache_mem_if.rsp_valid = 1'b0;
    bitstream_cache_mem_if.rsp_data = '0;

    repeat (10) @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
  endtask

  // =========================================================================
  // Test Stimulus
  // =========================================================================
  initial begin
    // Apply reset
    apply_reset();
    
    $display("[%0t] fdr_top_tb: Reset complete", $time);

    // Test 1: Idle Check
    repeat (5) @(posedge clk);
    // Verify no unexpected outputs
    assert(fdr_if.valid == 1'b0) else $error("FDR valid unexpected high");
    
    $display("[%0t] fdr_top_tb: Test passed!", $time);
    `ifdef MODELSIM
        $finish; // Was $stop
    `else
        $finish;
    `endif
  end

  // =========================================================================
  // Waveform Dump (FSDB/VCD)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("fdr_top_tb.fsdb");
    $fsdbDumpvars(0, fdr_top_tb);
  end
`endif

`ifdef VCD
  initial begin
    $dumpfile("fdr_top_tb.vcd");
    $dumpvars(0, fdr_top_tb);
  end
`endif

endmodule
