// TODO: Change the BH interface to assert consumed instead of ready

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
    input  logic                                     last_in_i, // This implementation may need to be modified
    output logic                                     buffer_consumed_o,

    // Output to Branch Handler
    output logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] pred_out_o,
    output logic                                     valid_out_o,
    input  logic                                     consumed_i
  );

  typedef enum logic [1:0] {
    StateIdle,
    StateFill,
    StateDrain
  } state_e;

  state_e state_q, state_d;
  logic [DICE_NUM_MAX_THREADS_PER_CORE-1:0] pred_buffer;
  logic buffer_consumed_q, buffer_consumed_d;

  always_comb begin
    state_d = state_q;
    buffer_consumed_d = 1'b0;
    case (state_q)
      StateIdle: begin
        if (valid_in_i) begin
          if (last_in_i) begin
            state_d = StateDrain;
          end else begin
            state_d = StateFill;
          end
        end
      end
      StateFill: begin
        if (valid_in_i && last_in_i) begin
          state_d = StateDrain;
        end
      end
      StateDrain: begin
        if (consumed_i) begin
          state_d = StateIdle;
          buffer_consumed_d = 1'b1;
        end
      end
      default: begin
        state_d = StateIdle;
      end
    endcase
  end


  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      pred_buffer <= '0;
      state_q <= StateIdle;
      buffer_consumed_q <= 1'b0;
    end else begin
      state_q <= state_d;
      buffer_consumed_q <= buffer_consumed_d;
      if (valid_in_i) begin
        pred_buffer[tid_offset_i +: DATA_WIDTH] <= data_in_i;
      end
    end
  end

  assign valid_out_o = (state_q == StateDrain);
  assign pred_out_o = pred_buffer;
  assign buffer_consumed_o = buffer_consumed_q;

endmodule
