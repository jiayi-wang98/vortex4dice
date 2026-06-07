// =============================================================================
// dice_cgra_rf — Register File + CGRA fabric + operand-launch collector, fused
// into ONE wrapper (mirrors Mini_Dice dice_cgra_rf). Extracted from dice_core.
//
// Contains, under one boundary:
//   * dice_rf_ctrl       — the SRAM-banked GPR register file (read launch / CGRA
//                          result writeback / LDST writeback / const read path).
//   * dice_pred_rf       — the predicate register file (read -> fabric ext_pred_i,
//                          write <- fabric ext_pred_o).
//   * dice_top           — the BUILT 32-bit DORA CGRA fabric.
//   * launch path        — rf_launch_data_q / rf_launch_const_q registered on the
//                          RF read valid + the launch-tag latency shift_reg, so the
//                          operands present to the fabric aligned with its latency.
//   * special registers  — registered threadIdx / blockDim / blockIdx / gridDim
//                          storage, loaded on the SAME rf_rd_valid edge as the
//                          launch data so they reach the fabric's dedicated
//                          special-reg inputs aligned 1-for-1 with ext_data_i.
//   * result unpack      — fabric ext_data_o / ext_mem_o / ext_pred_o -> backend
//                          datapath (RF writeback, per-port mem ops, predicate wb).
//
// Keeping the launch register + the special-reg registers in the SAME module is
// load-bearing: they all load on rf_rd_valid and the fabric sees them together;
// splitting them across modules would silently break the 1-cycle alignment.
// =============================================================================
module dice_cgra_rf
  import dice_pkg::*;
  import dice_frontend_pkg::*;
  import DE_pkg::*;
(
    input  logic clk_i,
    input  logic rst_i,

    // CGRA enable is gated while the fabric is being (re)programmed.
    input  logic prog_busy_i,

    // ---- Read (operand launch) side — from the dispatcher ----
    input  logic [3:0]                     rd_tid_valid_i,
    input  logic [4*DICE_TID_WIDTH-1:0]    rd_tid_i,
    input  logic [`DICE_GPR_NUM-1:0]       gpr_bitmap_i,

    // In-flight e-block: fdr_active_i = comb select, fdr_active_q_i = registered.
    input  fdr_t fdr_active_i,
    input  fdr_t fdr_active_q_i,
    input  logic fdr_accept_i,         // new-e-block accept: clears the launch pipeline
    input  logic [DICE_EBLOCK_ID_WIDTH-1:0] dispatch_e_block_id_i,

    // ---- LDST writeback (from dice_ldst_retire) ----
    input  cache_wr_cmd rf_ldst_wr_i,
    input  logic        core_rsp_valid_i,   // line-level LDST valid (from the cache)
    output logic        rf_ldst_ready_o,    // RF LDST buffer can accept a line

    // ---- CGRA programming scanchain (from dice_cgra_prog) ----
    input  logic prog_rst_i,
    input  logic prog_done_i,
    input  logic prog_we_i,
    input  logic prog_din_i,

    // ---- CGRA result / launch tag (to the backend) ----
    output logic                            cgra_v_o,
    output logic [DICE_TID_WIDTH-1:0]       cgra_tid_o,
    output logic [DICE_EBLOCK_ID_WIDTH-1:0] cgra_e_block_id_o,

    // ---- CGRA memory ops (per port) -> dice_tmcu_mem_edge / credit ----
    output logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_valid_o,
    output logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_op_o,    // 0=ld 1=st
    output logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_addr_o,
    output logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_data_o,
    output logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] cgra_mem_rsp_addr_o,

    // ---- RF load-retire pops -> dice_brt ----
    output logic [DICE_NUM_BANKS-1:0]                  rf_ldst_pop_o,
    output logic [DICE_NUM_BANKS-1:0][EBLOCK_ID_W-1:0] rf_ldst_pop_e_block_id_o,
    output logic                                       rf_ldst_special_pop_o,
    output logic [EBLOCK_ID_W-1:0]                     rf_ldst_special_pop_e_block_id_o
);

  // ---------------------------------------------------------------------------
  // Local reshape of the fdr metadata ld_dest_regs (packed
  // [$clog2(DICE_CGRA_MEM_PORTS-1)][REG_INDEX_WIDTH]) into the
  // [NUM_MEM_PORTS][DICE_REG_ADDR_WIDTH] form the gen_* helpers + RF expect.
  // Missing ports get the "no load" sentinel (31).
  // ---------------------------------------------------------------------------
  function automatic logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] reshape_ld_dest(
      input logic [$clog2(`DICE_CGRA_MEM_PORTS-1):0][REG_INDEX_WIDTH-1:0] md_ld
  );
    for (int p = 0; p < NUM_MEM_PORTS; p++)
      reshape_ld_dest[p] = DICE_REG_ADDR_WIDTH'(31);
    for (int p = 0; p <= $clog2(`DICE_CGRA_MEM_PORTS-1); p++)
      reshape_ld_dest[p] = DICE_REG_ADDR_WIDTH'(md_ld[p]);
  endfunction

  // ---------------------------------------------------------------------------
  // RF datapath signals
  // ---------------------------------------------------------------------------
  logic                                          rf_rd_valid_lo;
  logic [DICE_NUM_BANKS*DICE_REG_DATA_WIDTH-1:0] rd_data_lo;
  logic                                          cgra_v_lo;
  logic [DICE_NUM_BANKS*DICE_REG_DATA_WIDTH-1:0] cgra_data_lo;
  logic [DICE_TID_WIDTH-1:0]                     cgra_tid_lo;

  logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_valid_lo;
  logic [NUM_MEM_PORTS-1:0]                          cgra_mem_port_op_lo;
  logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_addr_lo;
  logic [NUM_MEM_PORTS-1:0][DICE_REG_DATA_WIDTH-1:0] cgra_mem_data_lo;
  logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] cgra_mem_rsp_addr_lo;
  logic [DICE_EBLOCK_ID_WIDTH-1:0]                   cgra_e_block_id_lo;

  // RF retire / passthrough outputs.
  logic [DICE_TID_WIDTH-1:0]                          rf_tid_lo;
  logic [EBLOCK_ID_W-1:0]                             rf_e_block_id_lo;
  logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0]  rf_ld_dest_regs_lo;
  logic [$clog2(NUM_MEM_PORTS+1)-1:0]                 rf_num_stores_lo;
  logic [DICE_NUM_CONST*DICE_REG_DATA_WIDTH-1:0]      rf_const_data_lo;
  logic                                               rf_ldst_special_ready_lo;

  // Reshaped metadata for the RF.
  logic [NUM_MEM_PORTS-1:0][DICE_REG_ADDR_WIDTH-1:0] rf_ld_dest_regs_li;
  assign rf_ld_dest_regs_li = reshape_ld_dest(fdr_active_i.metadata.ld_dest_regs);

  logic [$clog2(NUM_MEM_PORTS+1)-1:0] rf_num_stores_li;
  assign rf_num_stores_li = $clog2(NUM_MEM_PORTS+1)'(fdr_active_i.metadata.num_stores);

  dice_rf_ctrl #(
      .NUM_PORTS(DICE_NUM_BANKS),
      .DATA_WIDTH(DICE_REG_DATA_WIDTH),
      .NUM_TID(512),
      .TID_WIDTH($clog2(512)),
      .DEPTH(512),
      .ADDR_WIDTH($clog2(512)),
      .NUM_SPECIAL_REG(16),
      .MAX_CTA_ID(65535),
      .CTA_ID_WIDTH($clog2(65535)),
      .BUF_DEPTH(8)
  ) u_dice_rf_ctrl (
      .clk_i(clk_i),
      .reset_i(rst_i),

      // Read (operand launch) side — from dispatcher (single-TID launch).
      .rd_tid_valid_i(rd_tid_valid_i[0]),
      .rd_tid_ready_o(),
      .rd_unroll_factor_i(fdr_active_i.metadata.unrolling_factor),
      .rd_en_i(rd_tid_valid_i[0]),
      .rd_tid_i(rd_tid_i),
      .rd_bitmap_i(gpr_bitmap_i),
      .rd_data_o(rd_data_lo),
      .rf_rd_valid_o(rf_rd_valid_lo),

      // Retire / commit passthrough (additive).
      .tid_o(rf_tid_lo),
      .e_block_id_i(EBLOCK_ID_W'(dispatch_e_block_id_i)),
      .e_block_id_o(rf_e_block_id_lo),
      .ld_dest_regs_i(rf_ld_dest_regs_li),
      .num_stores_i(rf_num_stores_li),
      .ld_dest_regs_o(rf_ld_dest_regs_lo),
      .num_stores_o(rf_num_stores_lo),

      // CONST read path for the fabric lane map (registered to read latency).
      .rd_const_data_o(rf_const_data_lo),

      // LOAD-RETIRE outputs -> dice_brt.
      .ldst_pop_o(rf_ldst_pop_o),
      .ldst_pop_e_block_id_o(rf_ldst_pop_e_block_id_o),
      .ldst_special_pop_o(rf_ldst_special_pop_o),
      .ldst_special_pop_e_block_id_o(rf_ldst_special_pop_e_block_id_o),
      .ldst_special_ready_o(rf_ldst_special_ready_lo),

      // Write (CGRA result) side — from the fabric result below.
      .cgra_tid_i(cgra_tid_lo),
      .cgra_data_i(cgra_data_lo),
      .wr_bitmap_i(fdr_active_q_i.metadata.out_regs_bitmap),
      .cgra_valid_i(cgra_v_lo),

      // LDST writeback — packed cache_wr_cmd from dice_ldst_retire. Line-level valid.
      .ldst_wr_i(rf_ldst_wr_i),
      .ldst_valid_i(core_rsp_valid_i),
      .ldst_ready_o(rf_ldst_ready_o),

      // const values are not in the FDR metadata yet -> tied 0 (deferred).
      .const_reg_i('0)
  );

  // ===========================================================================
  // RF -> CGRA launch path: register the RF read data on rf_rd_valid, tag with
  // the registered launch TID, and drive the fabric.
  // ===========================================================================
  localparam int MAX_PIPE_STAGE = 16;
  localparam int SHIFT_LAT_W    = $clog2(MAX_PIPE_STAGE);
  localparam int LAUNCH_TAG_W   = DICE_TID_WIDTH + 1;

  logic [DICE_NUM_BANKS*DICE_REG_DATA_WIDTH-1:0] rf_launch_data_q;
  logic [DICE_NUM_CONST*DICE_REG_DATA_WIDTH-1:0] rf_launch_const_q;
  logic                                          cgra_launch_valid_q;
  logic [DICE_TID_WIDTH-1:0]                      cgra_launch_tid_q;
  logic [LAUNCH_TAG_W-1:0]                        launch_tag_li;
  logic [LAUNCH_TAG_W-1:0]                        launch_tag_lo;
  logic [SHIFT_LAT_W-1:0]                         cgra_lat;

  // Launch TID sourced from the registered RF tid_o so the launch valid/TID align
  // with the registered RF read data + const data.
  assign cgra_launch_tid_q = rf_tid_lo;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      rf_launch_data_q    <= '0;
      rf_launch_const_q   <= '0;
      cgra_launch_valid_q <= 1'b0;
    end else begin
      cgra_launch_valid_q <= rf_rd_valid_lo;
      if (rf_rd_valid_lo) begin
        rf_launch_data_q  <= rd_data_lo;
        rf_launch_const_q <= rf_const_data_lo;
      end
    end
  end

  assign cgra_lat      = fdr_active_q_i.metadata.lat[SHIFT_LAT_W-1:0];
  assign launch_tag_li = {cgra_launch_valid_q, cgra_launch_tid_q};
  assign {cgra_v_lo, cgra_tid_lo} = launch_tag_lo;

  shift_reg #(
      .WIDTH(LAUNCH_TAG_W),
      .MAX_PIPE_STAGE(MAX_PIPE_STAGE)
  ) u_launch_tag_shift (
      .clk_i(clk_i),
      .reset_i(rst_i),
      .clear_i(fdr_accept_i),
      .latency(cgra_lat),
      .in_data(launch_tag_li),
      .out_data(launch_tag_lo)
  );

  // ===========================================================================
  // Special registers (threadIdx / blockIdx / blockDim / gridDim / const).
  // Registered storage loaded on the launch (rf_rd_valid) so they align 1-for-1
  // with rf_launch_data_q. threadIdx is decomposed from the registered launch TID
  // (rf_tid_lo) by blockDim; combinational divide/mod is behavioral (replace with
  // a pipelined divider before timing closure).
  // ===========================================================================
  localparam int LOCAL_TID_WIDTH = DICE_TID_WIDTH - DICE_HW_CTA_ID_WIDTH;
  logic [DICE_TID_WIDTH-1:0] spec_local_tid, spec_ntid_x, spec_ntid_y;
  logic [DICE_TID_WIDTH-1:0] tid_x_li, tid_y_li, tid_z_li, tid_yz_quot;
  always_comb begin
    spec_local_tid = DICE_TID_WIDTH'(rf_tid_lo[0 +: LOCAL_TID_WIDTH]);
    spec_ntid_x    = fdr_active_q_i.schedule_cta_size.x[DICE_TID_WIDTH-1:0];
    spec_ntid_y    = fdr_active_q_i.schedule_cta_size.y[DICE_TID_WIDTH-1:0];
    tid_x_li = '0; tid_y_li = '0; tid_z_li = '0; tid_yz_quot = '0;
    if (spec_ntid_x != '0) begin
      tid_x_li    = spec_local_tid % spec_ntid_x;
      tid_yz_quot = spec_local_tid / spec_ntid_x;
      if (spec_ntid_y != '0) begin
        tid_y_li = tid_yz_quot % spec_ntid_y;
        tid_z_li = tid_yz_quot / spec_ntid_y;
      end else begin
        tid_y_li = tid_yz_quot;
      end
    end
  end

  logic [DICE_REG_DATA_WIDTH-1:0] spec_const_q;
  logic [DICE_REG_DATA_WIDTH-1:0] spec_tid_x_q,    spec_tid_y_q,    spec_tid_z_q;
  logic [DICE_REG_DATA_WIDTH-1:0] spec_ntid_x_q,   spec_ntid_y_q,   spec_ntid_z_q;
  logic [DICE_REG_DATA_WIDTH-1:0] spec_ctaid_x_q,  spec_ctaid_y_q,  spec_ctaid_z_q;
  logic [DICE_REG_DATA_WIDTH-1:0] spec_nctaid_x_q, spec_nctaid_y_q, spec_nctaid_z_q;
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      spec_const_q    <= '0;
      spec_tid_x_q    <= '0; spec_tid_y_q    <= '0; spec_tid_z_q    <= '0;
      spec_ntid_x_q   <= '0; spec_ntid_y_q   <= '0; spec_ntid_z_q   <= '0;
      spec_ctaid_x_q  <= '0; spec_ctaid_y_q  <= '0; spec_ctaid_z_q  <= '0;
      spec_nctaid_x_q <= '0; spec_nctaid_y_q <= '0; spec_nctaid_z_q <= '0;
    end else if (rf_rd_valid_lo) begin
      spec_const_q    <= '0;
      spec_tid_x_q    <= DICE_REG_DATA_WIDTH'(tid_x_li);
      spec_tid_y_q    <= DICE_REG_DATA_WIDTH'(tid_y_li);
      spec_tid_z_q    <= DICE_REG_DATA_WIDTH'(tid_z_li);
      spec_ntid_x_q   <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_cta_size.x);
      spec_ntid_y_q   <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_cta_size.y);
      spec_ntid_z_q   <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_cta_size.z);
      spec_ctaid_x_q  <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_cta_id.x);
      spec_ctaid_y_q  <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_cta_id.y);
      spec_ctaid_z_q  <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_cta_id.z);
      spec_nctaid_x_q <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_grid_size.x);
      spec_nctaid_y_q <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_grid_size.y);
      spec_nctaid_z_q <= DICE_REG_DATA_WIDTH'(fdr_active_q_i.schedule_grid_size.z);
    end
  end

  // ===========================================================================
  // Predicate Register File (dice_pred_rf).
  //   Read: dispatcher PR slice of in_regs_bitmap -> fabric ext_pred_i.
  //   Write: fabric ext_pred_o -> PR slice of out_regs_bitmap.
  //   Bitmap layout (REG_NUM=32): GPR[0:15] | CR[16:23] | PR[24:31].
  // ===========================================================================
  localparam int PR_BITMAP_LSB = `DICE_GPR_NUM + `DICE_CR_NUM;

  logic [DICE_NUM_PRED-1:0]        pred_rd_data_lo;
  logic                            pred_rf_rd_valid_lo;
  logic [DICE_EBLOCK_ID_WIDTH-1:0] pred_rd_e_block_id_lo;
  logic [DICE_NUM_PRED-1:0]        cgra_ext_pred_o_packed;

  dice_pred_rf u_dice_pred_rf (
      .clk_i  (clk_i),
      .reset_i(rst_i),

      .rd_tid_valid_i   (|rd_tid_valid_i),
      .rd_tid_i         (rd_tid_i[0 +: DICE_TID_WIDTH]),
      .rd_pred_bitmap_i (fdr_active_i.metadata.in_regs_bitmap[PR_BITMAP_LSB +: DICE_NUM_PRED]),
      .rd_pred_data_o   (pred_rd_data_lo),
      .rf_rd_valid_o    (pred_rf_rd_valid_lo),

      .cgra_tid_i           (cgra_tid_lo),
      .cgra_pred_i          (cgra_ext_pred_o_packed),
      .cgra_pred_wr_bitmap_i(fdr_active_q_i.metadata.out_regs_bitmap[PR_BITMAP_LSB +: DICE_NUM_PRED]),
      .cgra_valid_i         (cgra_v_lo),

      .rd_e_block_id_i(dispatch_e_block_id_i),
      .rd_e_block_id_o(pred_rd_e_block_id_lo)
  );

  // ===========================================================================
  // CGRA fabric — the BUILT DORA fabric (dice_top).
  // ext_data_i lanes 0..15 = GPR banks (rf_launch_data_q), 16..23 = registered
  // CONST (rf_launch_const_q). Special-reg inputs from the registered storage.
  // ===========================================================================
  logic [DICE_REG_DATA_WIDTH-1:0] cgra_ext_data_o [0:23];
  logic                           cgra_ext_pred_o [0:7];
  logic [DICE_REG_DATA_WIDTH-1:0] cgra_ext_mem_o  [0:7];
  logic [7:0]                     cgra_ext_pred_i;
  logic                           cgra_prog_dout_lo;
  logic                           cgra_prog_we_lo;

  assign cgra_ext_pred_i = pred_rd_data_lo;

  dice_top u_dice_top (
      .clk_i  (clk_i),
      .reset_i(rst_i),
      .en_i   (~prog_busy_i),

      .ext_data_i_0 (rf_launch_data_q[ 0*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_1 (rf_launch_data_q[ 1*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_2 (rf_launch_data_q[ 2*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_3 (rf_launch_data_q[ 3*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_4 (rf_launch_data_q[ 4*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_5 (rf_launch_data_q[ 5*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_6 (rf_launch_data_q[ 6*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_7 (rf_launch_data_q[ 7*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_8 (rf_launch_data_q[ 8*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_9 (rf_launch_data_q[ 9*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_10(rf_launch_data_q[10*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_11(rf_launch_data_q[11*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_12(rf_launch_data_q[12*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_13(rf_launch_data_q[13*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_14(rf_launch_data_q[14*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_15(rf_launch_data_q[15*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_16(rf_launch_const_q[0*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_17(rf_launch_const_q[1*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_18(rf_launch_const_q[2*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_19(rf_launch_const_q[3*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_20(rf_launch_const_q[4*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_21(rf_launch_const_q[5*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_22(rf_launch_const_q[6*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),
      .ext_data_i_23(rf_launch_const_q[7*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH]),

      // Special registers from the REGISTERED storage above (aligned with ext_data_i).
      .const_data(spec_const_q),
      .tid_x(spec_tid_x_q),     .tid_y(spec_tid_y_q),     .tid_z(spec_tid_z_q),
      .ntid_x(spec_ntid_x_q),   .ntid_y(spec_ntid_y_q),   .ntid_z(spec_ntid_z_q),
      .ctaid_x(spec_ctaid_x_q), .ctaid_y(spec_ctaid_y_q), .ctaid_z(spec_ctaid_z_q),
      .nctaid_x(spec_nctaid_x_q),.nctaid_y(spec_nctaid_y_q),.nctaid_z(spec_nctaid_z_q),

      .ext_data_o_0 (cgra_ext_data_o[0]),  .ext_data_o_1 (cgra_ext_data_o[1]),
      .ext_data_o_2 (cgra_ext_data_o[2]),  .ext_data_o_3 (cgra_ext_data_o[3]),
      .ext_data_o_4 (cgra_ext_data_o[4]),  .ext_data_o_5 (cgra_ext_data_o[5]),
      .ext_data_o_6 (cgra_ext_data_o[6]),  .ext_data_o_7 (cgra_ext_data_o[7]),
      .ext_data_o_8 (cgra_ext_data_o[8]),  .ext_data_o_9 (cgra_ext_data_o[9]),
      .ext_data_o_10(cgra_ext_data_o[10]), .ext_data_o_11(cgra_ext_data_o[11]),
      .ext_data_o_12(cgra_ext_data_o[12]), .ext_data_o_13(cgra_ext_data_o[13]),
      .ext_data_o_14(cgra_ext_data_o[14]), .ext_data_o_15(cgra_ext_data_o[15]),
      .ext_data_o_16(cgra_ext_data_o[16]), .ext_data_o_17(cgra_ext_data_o[17]),
      .ext_data_o_18(cgra_ext_data_o[18]), .ext_data_o_19(cgra_ext_data_o[19]),
      .ext_data_o_20(cgra_ext_data_o[20]), .ext_data_o_21(cgra_ext_data_o[21]),
      .ext_data_o_22(cgra_ext_data_o[22]), .ext_data_o_23(cgra_ext_data_o[23]),

      .ext_pred_i_0(cgra_ext_pred_i[0]), .ext_pred_i_1(cgra_ext_pred_i[1]),
      .ext_pred_i_2(cgra_ext_pred_i[2]), .ext_pred_i_3(cgra_ext_pred_i[3]),
      .ext_pred_i_4(cgra_ext_pred_i[4]), .ext_pred_i_5(cgra_ext_pred_i[5]),
      .ext_pred_i_6(cgra_ext_pred_i[6]), .ext_pred_i_7(cgra_ext_pred_i[7]),
      .ext_pred_o_0(cgra_ext_pred_o[0]), .ext_pred_o_1(cgra_ext_pred_o[1]),
      .ext_pred_o_2(cgra_ext_pred_o[2]), .ext_pred_o_3(cgra_ext_pred_o[3]),
      .ext_pred_o_4(cgra_ext_pred_o[4]), .ext_pred_o_5(cgra_ext_pred_o[5]),
      .ext_pred_o_6(cgra_ext_pred_o[6]), .ext_pred_o_7(cgra_ext_pred_o[7]),

      .ext_mem_o_0(cgra_ext_mem_o[0]), .ext_mem_o_1(cgra_ext_mem_o[1]),
      .ext_mem_o_2(cgra_ext_mem_o[2]), .ext_mem_o_3(cgra_ext_mem_o[3]),
      .ext_mem_o_4(cgra_ext_mem_o[4]), .ext_mem_o_5(cgra_ext_mem_o[5]),
      .ext_mem_o_6(cgra_ext_mem_o[6]), .ext_mem_o_7(cgra_ext_mem_o[7]),

      .prog_clk_i (clk_i),
      .prog_rst_i (prog_rst_i),
      .prog_done_i(prog_done_i),
      .prog_we_i  (prog_we_i),
      .prog_din_i (prog_din_i),
      .prog_dout_o(cgra_prog_dout_lo),
      .prog_we_o  (cgra_prog_we_lo)
  );

  // Pack the fabric's unpacked ext_pred_o[0..7] into the predicate-RF write bus.
  always_comb begin
    for (int k = 0; k < DICE_NUM_PRED; k++)
      cgra_ext_pred_o_packed[k] = cgra_ext_pred_o[k];
  end

  // Pack fabric outputs into the backend datapath signals.
  always_comb begin
    cgra_data_lo = '0;
    for (int j = 0; j < 24; j++)
      cgra_data_lo[j*DICE_REG_DATA_WIDTH +: DICE_REG_DATA_WIDTH] = cgra_ext_data_o[j];

    // DORA packs ext_mem_o as INTERLEAVED {addr,data} pairs: lane 2k=addr, 2k+1=data.
    for (int p = 0; p < NUM_MEM_PORTS; p++) begin
      cgra_mem_addr_lo[p] = cgra_ext_mem_o[2*p];
      cgra_mem_data_lo[p] = cgra_ext_mem_o[2*p + 1];
    end
  end

  // Per-port valid/op from the e-block metadata, gated by CGRA result valid.
  assign cgra_mem_port_valid_lo = gen_mem_port_valid(reshape_ld_dest(fdr_active_q_i.metadata.ld_dest_regs),
                                                     fdr_active_q_i.metadata.num_stores)
                                & {NUM_MEM_PORTS{cgra_v_lo}};
  assign cgra_mem_port_op_lo    = gen_mem_port_op(reshape_ld_dest(fdr_active_q_i.metadata.ld_dest_regs),
                                                  fdr_active_q_i.metadata.num_stores)
                                & {NUM_MEM_PORTS{cgra_v_lo}};

  // Load destination register per port (writeback target for returning loads).
  // Missing ports stay 0 (no OOB read); distinct from the sentinel-31 reshape.
  always_comb begin
    cgra_mem_rsp_addr_lo = '0;
    for (int p = 0; p <= $clog2(`DICE_CGRA_MEM_PORTS-1); p++)
      cgra_mem_rsp_addr_lo[p] =
          DICE_REG_ADDR_WIDTH'(fdr_active_q_i.metadata.ld_dest_regs[p]);
  end

  assign cgra_e_block_id_lo = fdr_active_q_i.schedule_eblock_id;

  // ---- module outputs ----
  assign cgra_v_o              = cgra_v_lo;
  assign cgra_tid_o            = cgra_tid_lo;
  assign cgra_e_block_id_o     = cgra_e_block_id_lo;
  assign cgra_mem_port_valid_o = cgra_mem_port_valid_lo;
  assign cgra_mem_port_op_o    = cgra_mem_port_op_lo;
  assign cgra_mem_addr_o       = cgra_mem_addr_lo;
  assign cgra_mem_data_o       = cgra_mem_data_lo;
  assign cgra_mem_rsp_addr_o   = cgra_mem_rsp_addr_lo;

endmodule
