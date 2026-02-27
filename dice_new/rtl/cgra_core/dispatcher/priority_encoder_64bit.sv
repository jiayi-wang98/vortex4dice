module priority_encoder_64bit
    import DE_pkg::*;
(
    input logic [LANE_SIZE-1:0] data_in,        // Lane-wide input data
    input logic [LANE_WIDTH-1:0] start_pos,     // Starting position for search

    output logic [LANE_WIDTH-1:0] encoded_out,  // Encoded position of first set bit
    output logic valid                           // Valid output (1 if any bit found)
);

    // Number of 8-bit chunks that make up the lane
    localparam int NUM_CHUNKS = LANE_SIZE / 8;

    // Break down start_pos into chunk index and bit-within-chunk
    wire [$clog2(NUM_CHUNKS)-1:0] start_chunk = start_pos[LANE_WIDTH-1:3];
    wire [2:0]                    start_bit    = start_pos[2:0];

    // Signals for 8-bit priority encoders
    logic [7:0]                    chunk_data      [NUM_CHUNKS];
    logic [2:0]                    chunk_start_pos [NUM_CHUNKS];
    logic [2:0]                    chunk_encoded   [NUM_CHUNKS];
    logic                          chunk_valid     [NUM_CHUNKS];

    // Second stage signals
    logic [NUM_CHUNKS-1:0]         chunk_valid_mask;
    logic [$clog2(NUM_CHUNKS)-1:0] winning_chunk;
    logic                          second_stage_valid;

    // Split data_in into NUM_CHUNKS chunks of 8 bits
    always_comb begin
        for (int i = 0; i < NUM_CHUNKS; i++) begin
            chunk_data[i] = data_in[i*8 +: 8];
        end
    end

    // Set start positions for each chunk
    always_comb begin
        for (int i = 0; i < NUM_CHUNKS; i++) begin
            if (i < start_chunk) begin
                chunk_start_pos[i] = 3'b111;  // Skip chunks before start_chunk
            end else if (i == start_chunk) begin
                chunk_start_pos[i] = start_bit;
            end else begin
                chunk_start_pos[i] = 3'b000;
            end
        end
    end

    // Generate 8-bit priority encoders for each chunk
    genvar i;
    generate
        for (i = 0; i < NUM_CHUNKS; i++) begin : gen_8bit_encoders
            priority_encoder_8bit pe8 (
                .data_in(chunk_data[i]),
                .start_pos(chunk_start_pos[i]),
                .encoded_out(chunk_encoded[i]),
                .valid(chunk_valid[i])
            );
        end
    endgenerate

    // Create valid mask for second stage, masking out chunks before start_chunk
    always_comb begin
        chunk_valid_mask = {NUM_CHUNKS{1'b0}};
        for (int i = 0; i < NUM_CHUNKS; i++) begin
            if (i >= start_chunk) begin
                chunk_valid_mask[i] = chunk_valid[i];
            end else begin
                chunk_valid_mask[i] = 1'b0;
            end
        end
    end

    // Second stage: 8-bit priority encoder selects among valid chunks
    logic [2:0] second_stage_start_pos;
    assign second_stage_start_pos = start_chunk[$clog2(NUM_CHUNKS)-1:0];

    priority_encoder_8bit second_stage_pe (
        .data_in(chunk_valid_mask[7:0]),        // NOTE: works for NUM_CHUNKS <= 8 (LANE_SIZE <= 64)
        .start_pos(second_stage_start_pos),
        .encoded_out(winning_chunk[$clog2(NUM_CHUNKS)-1:0]),
        .valid(second_stage_valid)
    );

    // Final output generation
    always_comb begin
        if (second_stage_valid) begin
            encoded_out = {winning_chunk, chunk_encoded[winning_chunk]};
            valid = 1'b1;
        end else begin
            encoded_out = {LANE_WIDTH{1'b0}};
            valid = 1'b0;
        end
    end

endmodule
