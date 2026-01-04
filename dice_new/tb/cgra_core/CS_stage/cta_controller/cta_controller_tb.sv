`timescale 1ns/1ps
`include "dice_define.vh"

module cta_controller_tb;
  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int MaxNumCta = 4;
  localparam int CtaIndexWidth = $clog2(MaxNumCta);
  localparam int ThreadWidth = 256;
  localparam int PcWidth = 32;

  // =========================================================================
  // Testbench Signals
  // =========================================================================
  logic                                                                 clk;
  logic                                                                 rst;

  // DUT I/O
  logic                                                                 in_cta_valid_i;
  dice_pkg::dice_cta_desc_t                                             in_cta_desc_i;
  logic                                                                 in_cta_ready_o;

  logic                                                                 comp_cta_ready_i;
  logic                                                                 comp_cta_valid_o;
  dice_pkg::dice_cta_id_t                                               comp_cta_id_o;

  logic                                                                 pop_valid_o;
  logic                       [                      CtaIndexWidth-1:0] pop_hw_cta_id_o;
  logic                                                                 pop_ready_i;

  logic                                                                 add_ready_i;
  logic                                                                 add_valid_o;
  dice_pkg::dice_cta_desc_t                                             add_cta_info_o;
  logic                       [             dice_pkg::DICE_TID_WIDTH:0] add_cta_size_o;

  logic                                                                 init_valid_o;
  logic                                                                 init_ready_i;
  logic                       [                  $clog2(MaxNumCta)-1:0] init_hw_cta_id_o;
  logic                       [                                    1:0] init_hw_cta_size_o;
  logic                       [                            PcWidth-1:0] init_pc_o;
  logic                       [                            PcWidth-1:0] init_reconvergence_pc_o;

  dice_pkg::dice_cta_status_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] cta_status_table_i;
  logic                                                                 clear_entry_valid_o;
  logic                       [     dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] clear_entry_hw_id_o;

  logic                       [     dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] next_empty_cta_index_i;
  logic                       [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_status_i;

  logic                                                                 pop_out_valid_i;
  dice_pkg::dice_cta_id_t                                               pop_out_cta_id_i;

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  cta_controller #(
      .MAX_NUM_CTA    (MaxNumCta),
      .CTA_INDEX_WIDTH(CtaIndexWidth),
      .THREAD_WIDTH   (ThreadWidth),
      .PC_WIDTH       (PcWidth)
  ) u_dut (
      .clk_i                  (clk),
      .rst_i                  (rst),
      .in_cta_valid_i         (in_cta_valid_i),
      .in_cta_desc_i          (in_cta_desc_i),
      .in_cta_ready_o         (in_cta_ready_o),
      .comp_cta_ready_i       (comp_cta_ready_i),
      .comp_cta_valid_o       (comp_cta_valid_o),
      .comp_cta_id_o          (comp_cta_id_o),
      .pop_valid_o            (pop_valid_o),
      .pop_hw_cta_id_o        (pop_hw_cta_id_o),
      .pop_ready_i            (pop_ready_i),
      .add_ready_i            (add_ready_i),
      .add_valid_o            (add_valid_o),
      .add_cta_info_o         (add_cta_info_o),
      .add_cta_size_o         (add_cta_size_o),
      .init_valid_o           (init_valid_o),
      .init_ready_i           (init_ready_i),
      .init_hw_cta_id_o       (init_hw_cta_id_o),
      .init_hw_cta_size_o     (init_hw_cta_size_o),
      .init_pc_o              (init_pc_o),
      .init_reconvergence_pc_o(init_reconvergence_pc_o),
      .cta_status_table_i     (cta_status_table_i),
      .clear_entry_valid_o    (clear_entry_valid_o),
      .clear_entry_hw_id_o    (clear_entry_hw_id_o),
      .next_empty_cta_index_i (next_empty_cta_index_i),
      .active_cta_status_i    (active_cta_status_i),
      .pop_out_valid_i        (pop_out_valid_i),
      .pop_out_cta_id_i       (pop_out_cta_id_i)
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
    in_cta_valid_i         = 1'b0;
    in_cta_desc_i          = '0;
    comp_cta_ready_i       = 1'b1;
    pop_ready_i            = 1'b1;
    add_ready_i            = 1'b1;
    init_ready_i           = 1'b1;
    cta_status_table_i     = '0;
    next_empty_cta_index_i = '0;
    active_cta_status_i    = '0;
    pop_out_valid_i        = 1'b0;
    pop_out_cta_id_i       = '0;

    apply_reset();

    // TODO: Add test vectors here
    $display("[%0t] cta_controller_tb: Test passed!", $time);
    $finish;
  end

  // =========================================================================
  // Waveform Dump (FSDB)
  // =========================================================================
`ifdef FSDB
  initial begin
    $fsdbDumpfile("cta_controller_tb.fsdb");
    $fsdbDumpvars(0, cta_controller_tb);
  end
`endif

endmodule
