module thread_lane_reroute
    import dice_pkg::*,
           DE_pkg::*;
(
    input logic clk,                     // Clock signal
    input logic rst_n,                   // Active low reset signal
    input logic [1:0] unrolling_factor,  // Unrolling factor (00=1, 01=2, 10=4)
    input logic [CHUNK_ADDR_WIDTH-1:0] chunk_base_addr, // Chunk base address

    output logic [NUM_LANES-1:0] update_next_active_thread_logic,

    input logic [NUM_LANES-1:0] fifo_pop,
    // Inputs from next_active_thread_logic (chunk-local indices)
    input logic [$clog2(CHUNK_SIZE)-1:0] next_tid_0,
    input logic valid_0,
    input logic [$clog2(CHUNK_SIZE)-1:0] next_tid_1,
    input logic valid_1,
    input logic [$clog2(CHUNK_SIZE)-1:0] next_tid_2,
    input logic valid_2,
    input logic [$clog2(CHUNK_SIZE)-1:0] next_tid_3,
    input logic valid_3,

    output logic [2*DICE_TID_WIDTH-1:0] fifo_data_0, // {compare_tid, real_tid}
    output logic [2*DICE_TID_WIDTH-1:0] fifo_data_1,
    output logic [2*DICE_TID_WIDTH-1:0] fifo_data_2,
    output logic [2*DICE_TID_WIDTH-1:0] fifo_data_3,

    output logic [NUM_LANES-1:0] fifo_data_valid
);

    logic [NUM_LANES-1:0] valid;
    assign valid = {valid_3, valid_2, valid_1, valid_0};

    logic [NUM_LANES-1:0]            fifo_push;
    logic [NUM_LANES-1:0]            pre_fifo_pop;
    logic [2*DICE_TID_WIDTH-1:0]     fifo_push_data [NUM_LANES];
    logic [NUM_LANES-1:0]            full;

    // Full TID = {chunk_base_addr, chunk-local index} = DICE_TID_WIDTH bits
    logic [DICE_TID_WIDTH-1:0] fifo_full_tid [NUM_LANES];
    logic [2*DICE_TID_WIDTH-1:0] fifo_data [NUM_LANES];
    assign fifo_data_0 = fifo_data[0];
    assign fifo_data_1 = fifo_data[1];
    assign fifo_data_2 = fifo_data[2];
    assign fifo_data_3 = fifo_data[3];

    always_comb begin
        fifo_full_tid[0] = {chunk_base_addr, next_tid_0};
        fifo_full_tid[1] = {chunk_base_addr, next_tid_1};
        fifo_full_tid[2] = {chunk_base_addr, next_tid_2};
        fifo_full_tid[3] = {chunk_base_addr, next_tid_3};
    end

    assign update_next_active_thread_logic[0] = pre_fifo_pop[0] && valid_0;
    assign update_next_active_thread_logic[1] = pre_fifo_pop[1] && valid_1;
    assign update_next_active_thread_logic[2] = pre_fifo_pop[2] && valid_2;
    assign update_next_active_thread_logic[3] = pre_fifo_pop[3] && valid_3;

    // Selection logic based on unrolling factor
    always_comb begin
        for (int j = 0; j < NUM_LANES; j++) begin
            pre_fifo_pop[j]    = 1'b0;
            fifo_push[j]       = 1'b0;
            fifo_push_data[j]  = {2*DICE_TID_WIDTH{1'b0}};
        end

        case (unrolling_factor)
            2'b10: begin // unrolling_factor = 4
                // All 4 lanes dispatch independently.
                // compare_tid subtracts the lane's interleave offset (i*8) to get canonical ordering.
                if (valid[0] && !full[0]) begin
                    fifo_push_data[0] = {fifo_full_tid[0],                              fifo_full_tid[0]};
                    fifo_push[0]   = 1'b1;
                    pre_fifo_pop[0] = 1'b1;
                end
                if (valid[1] && !full[1]) begin
                    fifo_push_data[1] = {fifo_full_tid[1] - DICE_TID_WIDTH'(8),  fifo_full_tid[1]};
                    fifo_push[1]   = 1'b1;
                    pre_fifo_pop[1] = 1'b1;
                end
                if (valid[2] && !full[2]) begin
                    fifo_push_data[2] = {fifo_full_tid[2] - DICE_TID_WIDTH'(16), fifo_full_tid[2]};
                    fifo_push[2]   = 1'b1;
                    pre_fifo_pop[2] = 1'b1;
                end
                if (valid[3] && !full[3]) begin
                    fifo_push_data[3] = {fifo_full_tid[3] - DICE_TID_WIDTH'(24), fifo_full_tid[3]};
                    fifo_push[3]   = 1'b1;
                    pre_fifo_pop[3] = 1'b1;
                end
            end

            2'b01: begin // unrolling_factor = 2
                // Lanes 0 and 2 compete for output 0 (lane 0 has priority)
                if (valid[0] && !full[0]) begin
                    fifo_push_data[0] = {fifo_full_tid[0], fifo_full_tid[0]};
                    fifo_push[0]   = 1'b1;
                    pre_fifo_pop[0] = 1'b1;
                end else if (valid[2] && !full[0]) begin
                    fifo_push_data[0] = {fifo_full_tid[2], fifo_full_tid[2]};
                    fifo_push[0]   = 1'b1;
                    pre_fifo_pop[2] = 1'b1;
                end

                // Lanes 1 and 3 compete for output 1 (lane 1 has priority)
                if (valid[1] && !full[1]) begin
                    fifo_push_data[1] = {fifo_full_tid[1] - DICE_TID_WIDTH'(16), fifo_full_tid[1]};
                    fifo_push[1]   = 1'b1;
                    pre_fifo_pop[1] = 1'b1;
                end else if (valid[3] && !full[1]) begin
                    fifo_push_data[1] = {fifo_full_tid[3] - DICE_TID_WIDTH'(16), fifo_full_tid[3]};
                    fifo_push[1]   = 1'b1;
                    pre_fifo_pop[3] = 1'b1;
                end

                // Outputs 2 and 3 unused for UF=2
                fifo_push[2] = 1'b0;
                fifo_push[3] = 1'b0;
            end

            2'b00: begin // unrolling_factor = 1
                // Priority selection: Lane 0 > Lane 1 > Lane 2 > Lane 3 → only output 0
                if (valid[0] && !full[0]) begin
                    fifo_push_data[0] = {fifo_full_tid[0], fifo_full_tid[0]};
                    fifo_push[0]   = 1'b1;
                    pre_fifo_pop[0] = 1'b1;
                end else if (valid[1] && !full[0]) begin
                    fifo_push_data[0] = {fifo_full_tid[1], fifo_full_tid[1]};
                    fifo_push[0]   = 1'b1;
                    pre_fifo_pop[1] = 1'b1;
                end else if (valid[2] && !full[0]) begin
                    fifo_push_data[0] = {fifo_full_tid[2], fifo_full_tid[2]};
                    fifo_push[0]   = 1'b1;
                    pre_fifo_pop[2] = 1'b1;
                end else if (valid[3] && !full[0]) begin
                    fifo_push_data[0] = {fifo_full_tid[3], fifo_full_tid[3]};
                    fifo_push[0]   = 1'b1;
                    pre_fifo_pop[3] = 1'b1;
                end

                // Outputs 1, 2, 3 unused for UF=1
                fifo_push[1] = 1'b0;
                fifo_push[2] = 1'b0;
                fifo_push[3] = 1'b0;
            end

            default: begin
                for (int j = 0; j < NUM_LANES; j++) begin
                    fifo_push[j]    = 1'b0;
                    pre_fifo_pop[j] = 1'b0;
                end
            end
        endcase
    end

    // Sync FIFOs: {compare_tid[DICE_TID_WIDTH-1:0], real_tid[DICE_TID_WIDTH-1:0]}
    genvar i;
    generate
        for (i = 0; i < NUM_LANES; i++) begin : gen_fifos
            sync_fifo_read_unreg #(
                .DATA_WIDTH(2*DICE_TID_WIDTH),
                .DEPTH(2)
            ) fifo_inst (
                .clk(clk),
                .rst(rst_n),
                .push(fifo_push[i]),
                .push_data(fifo_push_data[i]),
                .pop(fifo_pop[i]),
                .pop_data(fifo_data[i]),
                .pop_data_valid(fifo_data_valid[i]),
                .empty(),
                .full(full[i]),
                .count()
            );
        end
    endgenerate

endmodule
