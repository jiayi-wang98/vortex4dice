import frontend_pkg::*;
`include "VX_define.vh"

/*
TO DO: 
-add comms with status table, dispatcher...
-branch handler
-sort out some of the valid check sigs
-figure out best way to do parameters
*/

module fdr_top #(


)(
    input logic clk,
    input logic rst,

    // Vortex memory interface for reusing instruction cache
    // PLANNING FOR MEM SYS/CACHE TO BE INSTATIATED IN HIGHER LEVEL
    VX_mem_bus_if.master icache_bus_if,

    // DICE stage interfaces that still need to be defined
    cta_sched_if.slave   schedule_if,
    fdr_if.master        fdr_if,


    //simt stack
    input logic [PC_WIDTH-1:0] simt_stack_pc;

    // TO CGRA BUFFERS - MAY CHANGE TO INTERFACE    
    output logic [CHUNK_SIZE-1:0] cm0_data,
    output logic [NUM_CHUNKS-1:0] cm0_chunk_en,
    output logic [CHUNK_SIZE-1:0] cm1_data,
    output logic [NUM_CHUNKS-1:0] cm1_chunk_en


);

    logic fire_eblock_internal;

    //general metadata
    pgraph_meta_t meta_internal;
    logic meta_valid_internal;

    
    // Internal parts of meta
    logic [31:0] branch_meta_internal; 
    logic [31:0] bitstream_addr;  
    logic [7:0]  bitstream_length; //currently not given to bitstream fetch
    //(hanging and needs to be resolved/determine if that module needs it)

    // Misc Internal Sigs
    logic bitstream_addr_valid_internal, mask_valid_internal, done_streaming_internal;




    // -------------------------------------------------------------------------
    // META FETCH
    // -------------------------------------------------------------------------
    meta_fetch #( //NEED TO FIGURE OUT HOW TO BEST DEAL WITH REPEATEDLY USED PARAMS - RESEARCH THIS
        .MAX_NUM_CTA        (),
        .PC_WIDTH           (),
        .UUID_WIDTH         ()
    ) meta_fetch_inst (
        .clk                (clk),
        .rst_n              (rst)

        // From Scheduler
        .schedule_valid     (schedule_if.valid),
        .fdr_next_pc        (schedule_if.data.schedule_next_pc),
        // .schedule_uuid      (), //This is going to probably be e-block id
        .schedule_ready     (schedule_if.ready),

        .meta_fetch_bus_if  (icache_bus_if),

        // To decoder
        .outgoing_meta      (internal_meta),
        .meta_valid         (internal_meta_valid),

        .fire_eblock        (fire_eblock_internal)
    );

    // -------------------------------------------------------------------------
    // DECODER
    // -------------------------------------------------------------------------
    decode #(
        .MASK_WIDTH             ()
    ) decode_inst (
        // From meta fetch unit
        .metadata_in            (internal_meta),
        .meta_in_valid          (internal_meta_valid),

        // To bitstream fetch unit
        .bitstream_addr         (bitstream_addr),
        .bitstream_addr_valid   (bitstream_addr_valid_internal),
        .bitstream_length       (bitstream_length), //hanging

        // Branch handler
        .branch_metadata        (branch_meta_internal),
        .branch_req_valid       (),

        .real_active_thread_mask(), //repetitive
        .mask_valid             (), //repetitive

        // To valid checker
        .decode_valid           (mask_valid_internal), //repetitive

        // To fdr stage barrier
        .metadata_out           (fdr_if.data.metadata),
        .mask_out               (fdr_if.data.real_active_mask)
    );

    // -------------------------------------------------------------------------
    // BITSTREAM FETCH
    // -------------------------------------------------------------------------
    bitstream_fetch_load #( // bitstream length is hanging
        .BITSTREAM_ADDR_WIDTH   (),
        .BITSTREAM_SIZE         (),
        .CHUNK_SIZE             (),
        .NUM_CHUNKS             ()
    ) bitstream_fetch_load_inst (
        .clk                    (clk),
        .rst_n                  (rst),

        // From decoder
        .meta_valid             (bitstream_addr_valid_internal),
        .bitstream_addr         (bitstream_addr),

        // P-graph buffers (stream bitstream)
        .cm0_data               (cm0_data),
        .cm0_chunk_en           (cm0_chunk_en),

        .cm1_data               (cm1_data),
        .cm1_chunk_en           (cm1_chunk_en),

        // To valid checker
        .done_streaming         (done_streaming_internal),

        // Cache interface
        .cache_bus_if           (icache_bus_if),

        // To FDR EX buffer
        .cm_num                 (fdr_if.data.loaded_buffer)
    );

    // -------------------------------------------------------------------------
    // BRANCH HANDLER
    // -------------------------------------------------------------------------

    //UNFINISHED AS OF NOW -> SOME SCAFFOLDING DONE


    // -------------------------------------------------------------------------
    // VALID CHECKER (This is currently unfished and I know lots of the i/o is wrong)
    // -------------------------------------------------------------------------
    valid_check #(
        .PC_WIDTH           ()
    ) valid_check_inst (
        .clk                (clk),
        .rst                (rst), //

        // From decoder
        // .barrier_indicator  (), 
        .mask_valid         (mask_valid_internal),

        // From CS, FDR buffer
        .eblock_pc          (schedule_if.data.schedule_next_pc),
        .prefetch_block     (), //?

        // From SIMT_Stack
        .simt_stack_pc      (simt_stack_pc),

        .bitstream_loaded    (done_streaming_internal),

        // From cta status table
        .unresolved_div     (),
        .barrier            (),

        // To FDR DE buffer
        .fdr_valid          (fdr_if.valid),
        .ex_ready           (fdr_if.ready),

        .fire_eblock        (fire_eblock_internal)
    );

endmodule