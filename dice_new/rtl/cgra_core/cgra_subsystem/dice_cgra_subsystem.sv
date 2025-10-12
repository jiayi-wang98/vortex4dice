module dice_cgra_subsystem #(
    parameter int NUM_PORTS = 16,
    parameter int DATA_WIDTH = 32,
    parameter int NUM_TID = 512,
    parameter int RF_ADDR_WIDTH = $clog2(NUM_TID),
    parameter int MAX_IO_PIPE_STAGE = 8,
    parameter int MAX_CGRA_PIPE_STAGE = 32,
    parameter int NUM_RF_BANK = 16,
    parameter int CGRA_CFG_WIDTH = 16*156
)(
    input  logic                             clk,
    input  logic                             rst_n,
    input  logic                             clr,

    // From Dispatcher
    input  logic [$clog2(NUM_TID+1)-1:0]          disp_tid,
    input  logic                            disp_valid,
    // From metadata to control RF read/write enables
    input logic [NUM_RF_BANK-1:0]       rf_rd_en,
    input logic [NUM_RF_BANK-1:0]       rf_wr_en,
    input logic [NUM_RF_BANK-1:0]       rf_wr_pred_en,
    input logic [NUM_RF_BANK-1:0]       prf_rd_en,
    input logic [NUM_RF_BANK-1:0]       prf_wr_en,

    // Config
    // Latency control
    input  logic [NUM_PORTS*$clog2(MAX_IO_PIPE_STAGE+1)-1:0] rf_latency_in_cgra,
    input  logic [NUM_PORTS*$clog2(MAX_IO_PIPE_STAGE+1)-1:0] rf_latency_out_cgra,
    input  logic [NUM_PORTS*$clog2(MAX_IO_PIPE_STAGE+1)-1:0] prf_latency_in_cgra,
    input  logic [NUM_PORTS*$clog2(MAX_IO_PIPE_STAGE+1)-1:0] prf_latency_out_cgra,
    // RF address override
    input logic [NUM_PORTS*RF_ADDR_WIDTH-1:0] rd_override_enable,
    input logic [NUM_PORTS*RF_ADDR_WIDTH-1:0] rd_override_address,
    input logic [NUM_PORTS*RF_ADDR_WIDTH-1:0] wr_override_enable,
    input logic [NUM_PORTS*RF_ADDR_WIDTH-1:0] wr_override_address,
    // CGRA config
    input logic [$clog2(MAX_CGRA_PIPE_STAGE+1)-1:0] cgra_compute_latency,
    input logic [CGRA_CFG_WIDTH-1:0] cgra_cfg
);
    //-----------------------------------------------------------
    // Wires
    //-----------------------------------------------------------
    // CGRA I/O
    logic [DATA_WIDTH-1:0] N_in_t[0:7];
    logic [DATA_WIDTH-1:0] N_out_t[0:7];
    logic N_in_p[0:7];
    logic N_out_p[0:7];
    logic [DATA_WIDTH-1:0] E_in_t[0:7];
    logic [DATA_WIDTH-1:0] E_out_t[0:7];
    logic E_in_p[0:7];
    logic E_out_p[0:7];
    logic [DATA_WIDTH-1:0] S_in_t[0:7];
    logic [DATA_WIDTH-1:0] S_out_t[0:7];
    logic S_in_p[0:7];
    logic S_out_p[0:7];
    logic [DATA_WIDTH-1:0] W_in_t[0:7];
    logic [DATA_WIDTH-1:0] W_out_t[0:7];
    logic W_in_p[0:7];
    logic W_out_p[0:7];

    //indexer
    logic [DATA_WIDTH-1:0] CGRA_in_from_rf_t[0:15];
    logic [DATA_WIDTH-1:0] CGRA_out_to_rf_t[0:15];
    logic CGRA_in_from_rf_p[0:15];
    logic CGRA_out_to_rf_p[0:15];

    // Reorganize CGRA I/O
    // CGRA port order:
    //                        N
    //                 0 1 2 3 4 5 6 7
    //               8 9 10 11 12 13 14 15
    //    0     0 --|--------------------|-- 16      0    
    //    1     1 --|                    |-- 17      1
    //    2     2 --|                    |-- 18      2
    // W  3     3 --|                    |-- 19      3   E
    //    4     4 --|                    |-- 20      4
    //    5     5 --|                    |-- 21      5
    //    6     6 --|                    |-- 22      6  
    //    7     7 --|--------------------|-- 23      7      
    //              24 25 26 27 28 29 30 31
    //                  0 1 2 3 4 5 6 7
    //                         S
    always_comb begin
        for (int i=0; i<8; i++) begin
            W_in_t[i] = CGRA_in_from_rf_t[i];
            N_in_t[i] = CGRA_in_from_rf_t[i+8];
            E_in_t[i] = CGRA_in_from_rf_t[i+2*8];
            S_in_t[i] = CGRA_in_from_rf_t[i+3*8];

            CGRA_out_to_rf_t[i] = W_out_t[i];
            CGRA_out_to_rf_t[i+8] = N_out_t[i];
            CGRA_out_to_rf_t[i+2*8] = E_out_t[i];
            CGRA_out_to_rf_t[i+3*8] = S_out_t[i];

            W_in_p[i] = CGRA_in_from_rf_p[i];
            N_in_p[i] = CGRA_in_from_rf_p[i+8];
            E_in_p[i] = CGRA_in_from_rf_p[i+2*8];
            S_in_p[i] = CGRA_in_from_rf_p[i+3*8];

            CGRA_out_to_rf_p[i] = W_out_p[i];
            CGRA_out_to_rf_p[i+8] = N_out_p[i];
            CGRA_out_to_rf_p[i+2*8] = E_out_p[i];
            CGRA_out_to_rf_p[i+3*8] = S_out_p[i];
        end
    end
    // rf interface
    logic [NUM_RF_BANK*RF_ADDR_WIDTH-1:0] rf_rd_addr;
    logic [NUM_RF_BANK*RF_ADDR_WIDTH-1:0] rf_wr_addr;

    // cgra output tid and valid
    logic [$clog2(NUM_TID+1)-1:0] out_tid;
    logic out_valid;
    //-----------------------------------------------------------
    // TID Shift Register
    //-----------------------------------------------------------
    dice_cgra_tid_sr #(
      .TOTAL_TID(NUM_TID),
      .MAX_LATENCY(MAX_CGRA_PIPE_STAGE)
    ) u_tid_sr (
      .clk(clk),
      .rst_n(rst_n),
      .clr(clr),
      .latency(cgra_compute_latency), // Set appropriate latency
      .in_tid(disp_tid),
      .in_valid(disp_valid),
      .out_tid(out_tid),
      .out_valid(out_valid)
    );

    dice_rf_address_converter #(
        .NUM_BANK(NUM_RF_BANKS),
        .DEPTH(NUM_TID)
    ) u_rd_addr_conv (
        .disp_tid(disp_tid),
        .rf_addr(rf_rd_addr),
        .override_enable(rd_override_enable),
        .override_address(rd_override_address)
    );

    dice_rf_address_converter #(
      .NUM_BANK(NUM_BANKS),
      .DEPTH(NUM_TID)
    ) u_wr_addr_conv (
      .disp_tid(out_tid),
      .rf_addr(rf_wr_addr),
      .override_enable(wr_override_enable),
      .override_address(wr_override_address)
    );

    //register file
    logic [NUM_RF_BANKS*DATA_WIDTH-1:0] rf_rd_data;
    logic [NUM_RF_BANKS*DATA_WIDTH-1:0] rf_wr_data;

    logic [NUM_RF_BANKS-1:0] rf_wr_en_final;
    logic [NUM_RF_BANKS-1:0] prf_rd_data;
    logic [NUM_RF_BANKS-1:0] prf_wr_data;

    always_comb begin
        for (int i=0; i < NUM_RF_BANKS; i++) begin
            rf_wr_en_final[i] = rf_wr_en[i] & ( (~rf_wr_pred_en[i]) | cgra_out_to_rf_p[i*2+1]);
        end
    
    end

    dice_register_file #(
      .NUM_BANK(NUM_RF_BANKS),
      .WIDTH(DATA_WIDTH),
      .DEPTH(NUM_TID)
    ) u_rf_32 (
      .clk(clk),
      .rst_n(rst_n),
      .rd_en(rf_rd_en),
      .rd_addr(rf_rd_addr),
      .rd_data(rf_rd_data),
      .wr_en(rf_wr_en_final),
      .wr_addr(rf_wr_addr),
      .wr_data(rf_wr_data)
    );

    dice_register_file #(
      .NUM_BANK(NUM_RF_BANKS),
      .WIDTH(1),
      .DEPTH(NUM_TID)
    ) u_rf_pred (
      .clk(clk),
      .rst_n(rst_n),
      .rd_en(prf_rd_pred_en),
      .rd_addr(disp_tid),
      .rd_data(prf_rd_data),
      .wr_en(prf_wr_en),
      .wr_addr(out_tid),
      .wr_data(prf_wr_data)
    );

    //-----------------------------------------------------------
    // I/O Wrappers
    //----------------------------------------------------------
    cgra_port_io #(
      .NUM_PORTS(NUM_PORTS),
      .WIDTH(DATA_WIDTH),
      .MAX_PIPE_STAGE(MAX_IO_PIPE_STAGE)
    ) u_cgra_rf_io_warpper (
      .clk(clk),
      .rst_n(rst_n),
      .clr(clr),
      .latency_in(latency_in),
      .latency_out(latency_out),
      .rf_rdata(rf_rd_data),
      .rf_wr_en(rf_wr_en),
      .rf_wdata(rf_wr_data),
      .cgra_in({W_in_t[0], W_in_t[2], W_in_t[4], W_in_t[6],
                 N_in_t[0], N_in_t[2], N_in_t[4], N_in_t[6],
                 E_in_t[0], E_in_t[2], E_in_t[4], E_in_t[6],
                 S_in_t[0], S_in_t[2], S_in_t[4], S_in_t[6]}),
      .cgra_out({W_out_t[0], W_out_t[2], W_out_t[4], W_out_t[6],
                 N_out_t[0], N_out_t[2], N_out_t[4], N_out_t[6],
                 E_out_t[0], E_out_t[2], E_out_t[4], E_out_t[6],
                 S_out_t[0], S_out_t[2], S_out_t[4], S_out_t[6]}),
      .cgra_pred_out({W_out_p[0], W_out_p[2], W_out_p[4], W_out_p[6],
                      N_out_p[0], N_out_p[2], N_out_p[4], N_out_p[6],
                      E_out_p[0], E_out_p[2], E_out_p[4], E_out_p[6],
                      S_out_p[0], S_out_p[2], S_out_p[4], S_out_p[6]})
    );


    //-----------------------------------------------------------
    // CGRA
    //-----------------------------------------------------------
    dice_cgra u_cgra (
      .clk(clk),
      .rst_n(rst_n),
      // North I/O
      .CGRA_N_in_t0(N_in_t[0]), .CGRA_N_in_t1(N_in_t[1]),
      .CGRA_N_in_t2(N_in_t[2]), .CGRA_N_in_t3(N_in_t[3]),
      .CGRA_N_in_t4(N_in_t[4]), .CGRA_N_in_t5(N_in_t[5]),
      .CGRA_N_in_t6(N_in_t[6]), .CGRA_N_in_t7(N_in_t[7]),
      .CGRA_N_out_t0(N_out_t[0]), .CGRA_N_out_t1(N_out_t[1]),
      .CGRA_N_out_t2(N_out_t[2]), .CGRA_N_out_t3(N_out_t[3]),
      .CGRA_N_out_t4(N_out_t[4]), .CGRA_N_out_t5(N_out_t[5]),
      .CGRA_N_out_t6(N_out_t[6]), .CGRA_N_out_t7(N_out_t[7]),
      .CGRA_N_in_p0(N_in_p[0]), .CGRA_N_in_p1(N_in_p[1]),
      .CGRA_N_in_p2(N_in_p[2]), .CGRA_N_in_p3(N_in_p[3]),
      .CGRA_N_in_p4(N_in_p[4]), .CGRA_N_in_p5(N_in_p[5]),
      .CGRA_N_in_p6(N_in_p[6]), .CGRA_N_in_p7(N_in_p[7]),
      .CGRA_N_out_p0(N_out_p[0]), .CGRA_N_out_p1(N_out_p[1]),
      .CGRA_N_out_p2(N_out_p[2]), .CGRA_N_out_p3(N_out_p[3]),
      .CGRA_N_out_p4(N_out_p[4]), .CGRA_N_out_p5(N_out_p[5]),
      .CGRA_N_out_p6(N_out_p[6]), .CGRA_N_out_p7(N_out_p[7]),
      // East I/O
      .CGRA_E_in_t0(E_in_t[0]), .CGRA_E_in_t1(E_in_t[1]),
      .CGRA_E_in_t2(E_in_t[2]), .CGRA_E_in_t3(E_in_t[3]),
      .CGRA_E_in_t4(E_in_t[4]), .CGRA_E_in_t5(E_in_t[5]),
      .CGRA_E_in_t6(E_in_t[6]), .CGRA_E_in_t7(E_in_t[7]),
      .CGRA_E_out_t0(E_out_t[0]), .CGRA_E_out_t1(E_out_t[1]),
      .CGRA_E_out_t2(E_out_t[2]), .CGRA_E_out_t3(E_out_t[3]),
      .CGRA_E_out_t4(E_out_t[4]), .CGRA_E_out_t5(E_out_t[5]),
      .CGRA_E_out_t6(E_out_t[6]), .CGRA_E_out_t7(E_out_t[7]),
      .CGRA_E_in_p0(E_in_p[0]), .CGRA_E_in_p1(E_in_p[1]),
      .CGRA_E_in_p2(E_in_p[2]), .CGRA_E_in_p3(E_in_p[3]),
      .CGRA_E_in_p4(E_in_p[4]), .CGRA_E_in_p5(E_in_p[5]),
      .CGRA_E_in_p6(E_in_p[6]), .CGRA_E_in_p7(E_in_p[7]),
      .CGRA_E_out_p0(E_out_p[0]), .CGRA_E_out_p1(E_out_p[1]),
      .CGRA_E_out_p2(E_out_p[2]), .CGRA_E_out_p3(E_out_p[3]),
      .CGRA_E_out_p4(E_out_p[4]), .CGRA_E_out_p5(E_out_p[5]),
      .CGRA_E_out_p6(E_out_p[6]), .CGRA_E_out_p7(E_out_p[7]),
      // South I/O
      .CGRA_S_in_t0(S_in_t[0]), .CGRA_S_in_t1(S_in_t[1]),
      .CGRA_S_in_t2(S_in_t[2]), .CGRA_S_in_t3(S_in_t[3]),
      .CGRA_S_in_t4(S_in_t[4]), .CGRA_S_in_t5(S_in_t[5]),
      .CGRA_S_in_t6(S_in_t[6]), .CGRA_S_in_t7(S_in_t[7]),
      .CGRA_S_out_t0(S_out_t[0]), .CGRA_S_out_t1(S_out_t[1]),
      .CGRA_S_out_t2(S_out_t[2]), .CGRA_S_out_t3(S_out_t[3]),
      .CGRA_S_out_t4(S_out_t[4]), .CGRA_S_out_t5(S_out_t[5]),
      .CGRA_S_out_t6(S_out_t[6]), .CGRA_S_out_t7(S_out_t[7]),
      .CGRA_S_in_p0(S_in_p[0]), .CGRA_S_in_p1(S_in_p[1]),
      .CGRA_S_in_p2(S_in_p[2]), .CGRA_S_in_p3(S_in_p[3]),
      .CGRA_S_in_p4(S_in_p[4]), .CGRA_S_in_p5(S_in_p[5]),
      .CGRA_S_in_p6(S_in_p[6]), .CGRA_S_in_p7(S_in_p[7]),
      .CGRA_S_out_p0(S_out_p[0]), .CGRA_S_out_p1(S_out_p[1]),
      .CGRA_S_out_p2(S_out_p[2]), .CGRA_S_out_p3(S_out_p[3]),
      .CGRA_S_out_p4(S_out_p[4]), .CGRA_S_out_p5(S_out_p[5]),
      .CGRA_S_out_p6(S_out_p[6]), .CGRA_S_out_p7(S_out_p[7]),
      // West I/O
      .CGRA_W_in_t0(W_in_t[0]), .CGRA_W_in_t1(W_in_t[1]),
      .CGRA_W_in_t2(W_in_t[2]), .CGRA_W_in_t3(W_in_t[3]),
      .CGRA_W_in_t4(W_in_t[4]), .CGRA_W_in_t5(W_in_t[5]),
      .CGRA_W_in_t6(W_in_t[6]), .CGRA_W_in_t7(W_in_t[7]),
      .CGRA_W_out_t0(W_out_t[0]), .CGRA_W_out_t1(W_out_t[1]),
      .CGRA_W_out_t2(W_out_t[2]), .CGRA_W_out_t3(W_out_t[3]),
      .CGRA_W_out_t4(W_out_t[4]), .CGRA_W_out_t5(W_out_t[5]),
      .CGRA_W_out_t6(W_out_t[6]), .CGRA_W_out_t7(W_out_t[7]),
      .CGRA_W_in_p0(W_in_p[0]), .CGRA_W_in_p1(W_in_p[1]),
      .CGRA_W_in_p2(W_in_p[2]), .CGRA_W_in_p3(W_in_p[3]),
      .CGRA_W_in_p4(W_in_p[4]), .CGRA_W_in_p5(W_in_p[5]),
      .CGRA_W_in_p6(W_in_p[6]), .CGRA_W_in_p7(W_in_p[7]),
      .CGRA_W_out_p0(W_out_p[0]), .CGRA_W_out_p1(W_out_p[1]),
      .CGRA_W_out_p2(W_out_p[2]), .CGRA_W_out_p3(W_out_p[3]),
      .CGRA_W_out_p4(W_out_p[4]), .CGRA_W_out_p5(W_out_p[5]),
      .CGRA_W_out_p6(W_out_p[6]), .CGRA_W_out_p7(W_out_p[7]),
      // TID and Valid
      .cgra_cfg(cgra_cfg)
    );


endmodule