module bh_buffer
  import dice_frontend_pkg::*;
  import dice_pkg::*;
  #(
    parameter DATA_WIDTH = 32
  )
  (
    input  logic                                     clk_i,
    input  logic                                     rst_i,

    // Input from CGRA Buffer
    input  logic [DATA_WIDTH-1:0]                    data_in_i,
    input  logic [DICE_TID_WIDTH-1:0]                tid_offset_i,
    input  logic                                     valid_in_i,
    input  logic                                     last_in_i,
    output logic                                     buffer_consumed_o,

    // Output to Branch Handler
    output logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] pred_out_o,
    output logic                                     valid_out_o,
    input  logic                                     consumed_i
  );

  logic [1:0][DICE_NUM_MAX_THREADS_PER_CORE-1:0] pred_slots_q, pred_slots_d;
  logic [1:0]                                    slot_full_q, slot_full_d;

  logic rd_ptr_q, rd_ptr_d;
  logic wr_ptr_q, wr_ptr_d;

  logic fill_active_q, fill_active_d;
  logic fill_slot_q, fill_slot_d;

  logic buffer_consumed_q, buffer_consumed_d;

  always_comb begin
    pred_slots_d      = pred_slots_q;
    slot_full_d       = slot_full_q;
    rd_ptr_d          = rd_ptr_q;
    wr_ptr_d          = wr_ptr_q;
    fill_active_d     = fill_active_q;
    fill_slot_d       = fill_slot_q;
    buffer_consumed_d = 1'b0;

    if (consumed_i && slot_full_q[rd_ptr_q]) begin
      slot_full_d[rd_ptr_q]  = 1'b0;
      pred_slots_d[rd_ptr_q] = '0;
      rd_ptr_d               = ~rd_ptr_q;
      buffer_consumed_d      = 1'b1;
    end

    if (valid_in_i) begin
      if (!fill_active_d) begin
        if (!slot_full_d[wr_ptr_d]) begin
          fill_active_d = 1'b1;
          fill_slot_d   = wr_ptr_d;
        end
      end

      if (fill_active_d) begin
        pred_slots_d[fill_slot_d][tid_offset_i +: DATA_WIDTH] = data_in_i;

        if (last_in_i) begin
          slot_full_d[fill_slot_d] = 1'b1;
          fill_active_d            = 1'b0;
          wr_ptr_d                 = ~fill_slot_d;
        end
      end
    end
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      pred_slots_q      <= '0;
      slot_full_q       <= '0;
      rd_ptr_q          <= 1'b0;
      wr_ptr_q          <= 1'b0;
      fill_active_q     <= 1'b0;
      fill_slot_q       <= 1'b0;
      buffer_consumed_q <= 1'b0;
    end else begin
      pred_slots_q      <= pred_slots_d;
      slot_full_q       <= slot_full_d;
      rd_ptr_q          <= rd_ptr_d;
      wr_ptr_q          <= wr_ptr_d;
      fill_active_q     <= fill_active_d;
      fill_slot_q       <= fill_slot_d;
      buffer_consumed_q <= buffer_consumed_d;
    end
  end

  assign valid_out_o       = slot_full_q[rd_ptr_q];
  assign pred_out_o        = pred_slots_q[rd_ptr_q];
  assign buffer_consumed_o = buffer_consumed_q;

endmodule
