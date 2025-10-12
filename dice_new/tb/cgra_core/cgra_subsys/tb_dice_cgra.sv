`timescale 1ns/1ps

module tb_dice_cgra;
  localparam TILE_BITS = 156;
  localparam NUM_TILES = 16;
  localparam NUM_BANKS = 16;
  localparam NUM_PORTS = 16;
  localparam NUM_TID = 512;
  localparam CFG_WIDTH = TILE_BITS * NUM_TILES;
  localparam ADDR_WIDTH = $clog2(NUM_TID);

  logic clk;
  logic rst_n;
  logic clr;
  logic [CFG_WIDTH-1:0] cgra_cfg;

  // Edge I/O signals
  logic [31:0] N_in_t [0:7], N_out_t [0:7];
  logic [31:0] E_in_t [0:7], E_out_t [0:7];
  logic [31:0] S_in_t [0:7], S_out_t [0:7];
  logic [31:0] W_in_t [0:7], W_out_t [0:7];

  logic N_in_p [0:7], N_out_p [0:7];
  logic E_in_p [0:7], E_out_p [0:7];
  logic S_in_p [0:7], S_out_p [0:7];
  logic W_in_p [0:7], W_out_p [0:7];

  //-----------------------------------------------------------
  // Clock / Reset
  //-----------------------------------------------------------
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    #50;
    rst_n = 1;
  end

  logic [8:0] dispatch_tid;
  logic disp_tid_valid;
  logic disp_enable;
  logic disp_clr;
  logic disp_done;

  logic [NUM_BANKS*ADDR_WIDTH-1:0] rd_override_enable;
  logic [NUM_BANKS*ADDR_WIDTH-1:0] rd_override_address;
  logic [NUM_BANKS*ADDR_WIDTH-1:0] rf_rd_addr;
  logic [NUM_BANKS*ADDR_WIDTH-1:0] wr_override_enable;
  logic [NUM_BANKS*ADDR_WIDTH-1:0] wr_override_address;
  logic [NUM_BANKS*ADDR_WIDTH-1:0] rf_wr_addr;

  //dispatcher tp hgen
  naive_dispatcher #(.TOTAL_TID(NUM_TID)) u_dispatcher
  (
    .clk(clk),
    .rst_n(rst_n),
    .enable(disp_enable),
    .clr(disp_clr),
    .max_tid(9'd255),
    .done(done),
    .dispatch_tid(dispatch_tid),
    .tid_valid(disp_tid_valid)
  );

  dice_rf_address_converter #(
    .NUM_BANK(NUM_BANKS),
    .DEPTH(NUM_TID)
  ) u_rd_addr_conv (
    .disp_tid(dispatch_tid),
    .rf_addr(rf_rd_addr),
    .override_enable(rd_override_enable),
    .override_address(rd_override_address)
  );

  //-----------------------------------------------------------
  // TID Shift Register
  //-----------------------------------------------------------
  logic [8:0] out_tid;
  logic out_valid;
  logic [4:0] cgra_compute_latency;

  dice_cgra_tid_sr #(
    .TOTAL_TID(NUM_TID),
    .MAX_LATENCY(32)
  ) u_tid_sr (
    .clk(clk),
    .rst_n(rst_n),
    .clr(disp_clr),
    .latency(cgra_compute_latency), // Set appropriate latency
    .in_tid(dispatch_tid),
    .in_valid(disp_tid_valid),
    .out_tid(out_tid),
    .out_valid(out_valid)
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

  //-----------------------------------------------------------
  // DUT
  //-----------------------------------------------------------
  dice_cgra dut (
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

  //-----------------------------------------------------------
  // I/O Wrappers
  //-----------------------------------------------------------
    //register file
  logic [NUM_BANKS-1:0] rf_rd_en;
  logic [NUM_BANKS*32-1:0] rf_rd_data;
  logic [NUM_BANKS-1:0] rf_wr_en;
  logic [NUM_BANKS*32-1:0] rf_wr_data;
  dice_register_file #(
    .NUM_BANK(16),
    .WIDTH(32),
    .DEPTH(512)
  ) u_rf_32 (
    .clk(clk),
    .rst_n(rst_n),
    .rd_en(rf_rd_en),
    .rd_addr(rf_rd_addr),
    .rd_data({rf_rd_data}),
    .wr_en(rf_wr_en),
    .wr_addr(rf_wr_addr),
    .wr_data(rf_wr_data)
  );

  logic [16*3-1:0] latency_in;
  logic [16*3-1:0] latency_out;
  cgra_port_io #(
    .NUM_PORTS(16),
    .WIDTH(32),
    .MAX_PIPE_STAGE(8)
  ) u_cgra_io_warpper (
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
                    S_out_p[0], S_out_p[2], S_out_p[4], S_out_p[6]}),
    .infile("input.txt"),
    .outfile("output.txt")
  );



  //-----------------------------------------------------------
  // Load configuration
  //-----------------------------------------------------------
  initial begin
    //setup address override
    rd_override_enable = '0;
    rd_override_address = '0;
    wr_override_enable = '0;
    wr_override_address = '0;
    //setup latency
    latency_in = '0;
    latency_out = '0;

    latency_in[0*3 +: 3] = 3'd0; // W0
    latency_in[2*3 +: 3] = 3'd1; // W2
    latency_in[4*3 +: 3] = 3'd2; // W4
    latency_in[6*3 +: 3] = 3'd3; // W6
    latency_in[8*3 +: 3] = 3'd0; // N0
    latency_in[10*3 +: 3] = 3'd1; // N2
    latency_in[12*3 +: 3] = 3'd2; // N4
    latency_in[14*3 +: 3] = 3'd3; // N6
    latency_in[16*3 +: 3] = 3'd0; // E0
    latency_in[18*3 +: 3] = 3'd1; // E2
    latency_in[20*3 +: 3] = 3'd2; // E4
    latency_in[22*3 +: 3] = 3'd3; // E6
    latency_out[0*3 +: 3] = 3'd0; // W0
    latency_out[2*3 +: 3] = 3'd1; // W2
    latency_out[4*3 +: 3] = 3'd2; // W4
    latency_out[6*3 +: 3] = 3'd3; // W6
    //setup dispatcher
    cgra_compute_latency = 5'd28; // Example compute latency

  end
  initial begin
    int fd;
    string line;
    int tile_idx = 0;
    int status;

    cgra_cfg = '0;
    fd = $fopen("bitstreams/bitstream.txt", "r");
    if (!fd) $fatal("Cannot open bitstream.txt");

    while (!$feof(fd) && tile_idx < NUM_TILES) begin
      status = $fgets(line, fd);
      line = line.trim();
      if (line.len() < TILE_BITS) continue;
      for (int b = 0; b < TILE_BITS; b++)
        cgra_cfg[tile_idx*TILE_BITS + (TILE_BITS-1 - b)] = (line[b] == "1");
      tile_idx++;
    end
    $fclose(fd);
    $display("[%0t] Loaded %0d tiles into CGRA config", $time, tile_idx);
  end

  //-----------------------------------------------------------
  // Test sequence
  //-----------------------------------------------------------
  initial begin
    wait(rst_n);
    #20;
    north_io.load_input();
    east_io.load_input();
    south_io.load_input();
    west_io.load_input();

    $display("[%0t] All input RAMs loaded", $time);
    repeat (1000) @(posedge clk);

    north_io.dump_output();
    east_io.dump_output();
    south_io.dump_output();
    west_io.dump_output();

    $display("[%0t] Simulation completed", $time);
    $finish;
  end

endmodule
