import frontend_pkg::*;
`include "VX_define.vh"

// Need to make interfaces still

module fdr_top #(

)(
    input logic clk,
    input logic rst,

    // Vortex memory interface for reusing instruction cache
    VX_mem_bus_if.master icache_bus_if,

    // DICE stage interfaces that still need to be defined
    schedule_if.slave   schedule_if,
    fdr_if.master       fdr_if
);

    logic fire_eblock_internal;

    // -------------------------------------------------------------------------
    // META FETCH
    // -------------------------------------------------------------------------
    meta_fetch #(
        .MAX_NUM_CTA        (),
        .PC_WIDTH           (),
        .UUID_WIDTH         ()
    ) meta_fetch_inst (
        .clk                (clk),
        .rst_n              (rts)

        // From Scheduler
        .schedule_valid     (),
        .fdr_next_pc        (),
        // .schedule_uuid      (), //This is going to probably be e-block id
        .schedule_ready     (),

        .meta_fetch_bus_if  (icache_bus_if),

        // To decoder
        .outgoing_meta      (),
        .meta_valid         (),

        // Feedback
        .fire_eblock        (fire_eblock_internal)
    );

    // -------------------------------------------------------------------------
    // DECODER
    // -------------------------------------------------------------------------
    decode #(
        .MASK_WIDTH             ()
    ) decode_inst (
        // From meta fetch unit
        .metadata_in            (),
        .meta_in_valid          (),

        // To bitstream fetch unit
        .bitstream_addr         (),
        .bitstream_addr_valid   (),
        .bitstream_length       (),

        // Branch handler
        .branch_metadata        (),
        .branch_req_valid       (),

        .real_active_thread_mask(),
        .mask_valid             (),

        // To valid checker
        .decode_valid           (),

        // To fdr stage barrier
        .metadata_out           (),
        .mask_out               ()
    );

    // -------------------------------------------------------------------------
    // BITSTREAM FETCH
    // -------------------------------------------------------------------------
    bitstream_fetch_load #(
        .BITSTREAM_ADDR_WIDTH   (),
        .BITSTREAM_SIZE         (),
        .CHUNK_SIZE             (),
        .NUM_CHUNKS             ()
    ) bitstream_fetch_load_inst (
        .clk                    (),
        .rst_n                  (),

        // From decoder
        .meta_valid             (),
        .bitstream_addr         (),

        // P-graph buffers (stream bitstream)
        .cm0_data               (),
        .cm0_chunk_en           (),

        .cm1_data               (),
        .cm1_chunk_en           (),

        // To valid checker
        .done_streaming         (),
        .fire_eblock            (),

        // Cache interface
        .cache_bus_if           (),

        // To FDR EX buffer
        .cm_num                 ()
    );

    // -------------------------------------------------------------------------
    // VALID CHECKER
    // -------------------------------------------------------------------------
    valid_check #(
        .PC_WIDTH           ()
    ) valid_check_inst (
        .clk                (),
        .rst_n              (),

        // From decoder
        .barrier_indicator  (),
        .mask_valid         (),
        .valid_ready        (),

        // From CS, FDR buffer
        .eblock_pc          (),
        .prefetch_block     (),

        // From SIMT_Stack
        .simt_stack_pc      (),

        .bitstream_valid    (),
        .bitstream_ready    (),

        // From cta status table
        .unresolved_div     (),
        .barrier            (),

        // To FDR DE buffer
        .fdr_valid          (),
        .ex_ready           (),

        .fire_eblock        (fire_eblock_internal)
    );

endmodule