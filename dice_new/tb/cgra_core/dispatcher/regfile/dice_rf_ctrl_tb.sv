`include "DE_pkg.sv"
`include "dice_pkg.sv"

module dice_rf_ctrl_tb;

import DE_pkg::*;
import dice_pkg::*;

    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam int NUM_PORTS       = DICE_NUM_BANKS;
    localparam int DATA_WIDTH      = DICE_REG_DATA_WIDTH;
    localparam int NUM_TID         = 512;
    localparam int TID_WIDTH       = $clog2(NUM_TID);
    localparam int DEPTH           = NUM_TID;
    localparam int ADDR_WIDTH      = $clog2(DEPTH);
    localparam int NUM_SPECIAL_REG = 16;
    localparam int MAX_CTA_ID      = 65535;
    localparam int CTA_ID_WIDTH    = $clog2(MAX_CTA_ID);

    // Clock period
    localparam int CLK_PERIOD = 10;

    //-------------------------------------------------------------------------
    // Clock and Reset
    //-------------------------------------------------------------------------
    logic clk_i;
    logic reset_i;

    //-------------------------------------------------------------------------
    // Read Interface Signals
    //-------------------------------------------------------------------------
    logic                             rd_tid_valid_i;
    logic                             rd_tid_ready_o;
    logic [1:0]                       rd_unroll_factor_i;
    logic                             rd_en_i;
    logic [(4*TID_WIDTH)-1:0]         rd_tid_i;
    logic [NUM_PORTS-1:0]             rd_bitmap_i;
    logic [NUM_PORTS*DATA_WIDTH-1:0]  rd_data_o;

    //-------------------------------------------------------------------------
    // Write Interface Signals (CGRA)
    //-------------------------------------------------------------------------
    reg_wr_cmd [NUM_PORTS-1:0]        cgra_wr_i;
    logic                             cgra_valid_i;

    //-------------------------------------------------------------------------
    // Write Interface Signals (LDST)
    //-------------------------------------------------------------------------
    reg_wr_cmd [NUM_PORTS-1:0]        ldst_wr_i;
    logic                             ldst_valid_i;
    logic                             ldst_ready_o;

    //-------------------------------------------------------------------------
    // Special Register Interface Signals
    //-------------------------------------------------------------------------

    logic [NUM_SPECIAL_REG-1:0]            clear_i;
    logic [NUM_SPECIAL_REG-1:0]            spec_rd_enable_i;
    logic [NUM_SPECIAL_REG*4-1:0]          spec_reg_sel_i;
    logic [NUM_SPECIAL_REG*DATA_WIDTH-1:0] const_reg_i;

    // TID info
    logic [TID_WIDTH-1:0]   tid_x_i;
    logic [TID_WIDTH-1:0]   tid_y_i;
    logic [TID_WIDTH-1:0]   tid_z_i;
    logic [TID_WIDTH-1:0]   ntid_x_i;
    logic [TID_WIDTH-1:0]   ntid_y_i;
    logic [TID_WIDTH-1:0]   ntid_z_i;
    logic [CTA_ID_WIDTH-1:0] ctaid_x_i;
    logic [CTA_ID_WIDTH-1:0] ctaid_y_i;
    logic [CTA_ID_WIDTH-1:0] ctaid_z_i;
    logic [CTA_ID_WIDTH-1:0] nctaid_x_i;
    logic [CTA_ID_WIDTH-1:0] nctaid_y_i;
    logic [CTA_ID_WIDTH-1:0] nctaid_z_i;

    // Special register output
    logic [NUM_SPECIAL_REG*DATA_WIDTH-1:0] spec_reg_out_o;

    //-------------------------------------------------------------------------
    // Clock Generation
    //-------------------------------------------------------------------------
    initial begin
        clk_i = 1'b0;
        forever #(CLK_PERIOD/2) clk_i = ~clk_i;
    end

    //-------------------------------------------------------------------------
    // DUT Instantiation
    //-------------------------------------------------------------------------
    dice_rf_ctrl #(
          .NUM_PORTS       (NUM_PORTS)
        , .DATA_WIDTH      (DATA_WIDTH)
        , .NUM_TID         (NUM_TID)
        , .TID_WIDTH       (TID_WIDTH)
        , .DEPTH           (DEPTH)
        , .ADDR_WIDTH      (ADDR_WIDTH)
        , .NUM_SPECIAL_REG (NUM_SPECIAL_REG)
        , .MAX_CTA_ID      (MAX_CTA_ID)
        , .CTA_ID_WIDTH    (CTA_ID_WIDTH)
    ) dut (
          .clk_i              (clk_i)           // clock
        , .reset_i            (reset_i)
        , .clear_i            (clear_i)
        // Read interface
        , .rd_tid_valid_i     (rd_tid_valid_i)
        , .rd_tid_ready_o     (rd_tid_ready_o)
        , .rd_unroll_factor_i (rd_unroll_factor_i)
        , .rd_en_i            (rd_en_i)
        , .rd_tid_i           (rd_tid_i)
        , .rd_bitmap_i        (rd_bitmap_i)
        , .rd_data_o          (rd_data_o)

        // CGRA write interface
        , .cgra_wr_i          (cgra_wr_i)
        , .cgra_valid_i       (cgra_valid_i)

        // LDST write interface
        , .ldst_wr_i          (ldst_wr_i)
        , .ldst_valid_i       (ldst_valid_i)
        , .ldst_ready_o       (ldst_ready_o)

        // Special register interface
        , .spec_rd_enable_i   (spec_rd_enable_i)
        , .spec_reg_sel_i     (spec_reg_sel_i)
        , .const_reg_i        (const_reg_i)
        , .tid_x_i            (tid_x_i)
        , .tid_y_i            (tid_y_i)
        , .tid_z_i            (tid_z_i)
        , .ntid_x_i           (ntid_x_i)
        , .ntid_y_i           (ntid_y_i)
        , .ntid_z_i           (ntid_z_i)
        , .ctaid_x_i          (ctaid_x_i)
        , .ctaid_y_i          (ctaid_y_i)
        , .ctaid_z_i          (ctaid_z_i)
        , .nctaid_x_i         (nctaid_x_i)
        , .nctaid_y_i         (nctaid_y_i)
        , .nctaid_z_i         (nctaid_z_i)
        , .spec_reg_out_o     (spec_reg_out_o)
    );

    //-------------------------------------------------------------------------
    // Tasks
    //-------------------------------------------------------------------------

    // Reset DUT task
    // Asserts reset for a specified number of cycles, then deasserts
    task reset_dut(input int num_cycles = 5);
        begin
            // Initialize all inputs to known state
            rd_tid_valid_i     = 1'b0;
            rd_unroll_factor_i = 2'b0;
            rd_en_i            = 1'b0;
            rd_tid_i           = '0;
            rd_bitmap_i        = '0;

            for (int i = 0; i < NUM_PORTS; i++) begin
                cgra_wr_i[i] = '0;
                ldst_wr_i[i] = '0;
            end
            cgra_valid_i = 1'b0;
            ldst_valid_i = 1'b0;

            spec_rd_enable_i = '0;
            spec_reg_sel_i   = '0;
            const_reg_i      = '0;

            tid_x_i    = '0;
            tid_y_i    = '0;
            tid_z_i    = '0;
            ntid_x_i   = '0;
            ntid_y_i   = '0;
            ntid_z_i   = '0;
            ctaid_x_i  = '0;
            ctaid_y_i  = '0;
            ctaid_z_i  = '0;
            nctaid_x_i = '0;
            nctaid_y_i = '0;
            nctaid_z_i = '0;

            // Assert reset
            reset_i = 1'b1;
            repeat (num_cycles) @(posedge clk_i);

            // Deassert reset
            reset_i = 1'b0;
            @(posedge clk_i);

            $display("[%0t] Reset complete", $time);
        end
    endtask

    initial begin
        void'($urandom(32'hdead_beef)); // seed once
    end

    //-------------------------------------------------------------------------
    // Functions
    //-------------------------------------------------------------------------

    // Generate a random reg_wr_cmd struct
    // Set we_enable to 1 to force write enable high, 0 to randomize it
    function automatic reg_wr_cmd gen_rand_reg_wr_cmd();
        reg_wr_cmd cmd;
        cmd.tid  = $urandom;
        cmd.ws   = $urandom;
        cmd.data = $urandom;
        cmd.we   = '1;
        return cmd;
    endfunction

    // Generate a random reg_wr_cmd with specific tid
    function automatic reg_wr_cmd gen_rand_reg_wr_cmd_with_tid(
          input logic [$clog2(NUM_TID)-1:0] tid
    );
        reg_wr_cmd cmd;
        cmd.tid  = tid;
        cmd.ws   = $urandom;
        cmd.data = $urandom;
        cmd.we   = '1;
        return cmd;
    endfunction

    // Generate a specific reg_wr_cmd (for directed tests)
    function automatic reg_wr_cmd gen_reg_wr_cmd(
          input logic [$clog2(NUM_TID)-1:0]   tid
        , input logic [$clog2(DICE_NUM_REGS)-1:0] ws
        , input logic [DICE_REG_DATA_WIDTH:0] data
        , input logic                         we
    );
        reg_wr_cmd cmd;
        cmd.tid  = tid;
        cmd.ws   = ws;
        cmd.data = data;
        cmd.we   = we;
        return cmd;
    endfunction

    // Task write cgra only
    task write_cgra_only();
        begin
            cgra_valid_i = 1'b1;
            for (int i = 0; i < NUM_PORTS; i++) begin
                cgra_wr_i[i] = gen_rand_reg_wr_cmd();
                $display("Writing to bank %0d: tid=%0d, ws=%0d, data=%0d", i, cgra_wr_i[i].tid, cgra_wr_i[i].ws, cgra_wr_i[i].data);
            end
            @(posedge clk_i);
            cgra_valid_i = 1'b0;
        end
    endtask


    task read_cgra_only();
        begin
            $display("Reading from cgra only");
            rd_tid_valid_i = 1'b1;
            rd_tid_i = $clog2(NUM_TID)'($urandom);
            rd_bitmap_i = NUM_PORTS'(32'b00000000_00000000_00000000_00000000_00000000_00000000_00000000_11111111);

            @(posedge clk_i);
            $display("Read data: %0d", rd_data_o);
            rd_tid_valid_i = 1'b0;
        end
    endtask




    //-------------------------------------------------------------------------
    // Main Test Sequence
    //-------------------------------------------------------------------------
    initial begin
        $display("=== dice_rf_ctrl Testbench Start ===");

        // Apply reset
        reset_dut(5);

        write_cgra_only();
        read_cgra_only();
        // End simulation
        #100;
        $display("=== dice_rf_ctrl Testbench End ===");
        $finish;
    end

endmodule
