module smem #(
  parameter int unsigned ADDR_W   = 10,   // depth = 2**ADDR_W
  parameter int unsigned DATA_W   = 256,  // must be multiple of 8
  parameter int unsigned TAG_W    = 0,    // 0 means no tag ports used
  parameter int unsigned RD_LAT   = 1     // fixed at 1 in this simple model
) (
  input  logic                     clk,
  input  logic                     rst,

  // command channel
  input  logic                     cmd_valid,
  output logic                     cmd_ready,

  input  logic                     rw,          // 1=write, 0=read
  input  logic [ADDR_W-1:0]        addr,
  input  logic [DATA_W-1:0]        write_data,
  input  logic [(DATA_W/8)-1:0]    write_byten,
  input  logic [TAG_W-1:0]         tag,

  // read response channel
  output logic                     rd_valid,
  input  logic                     outdata_ready,
  output logic [DATA_W-1:0]        read_data,
  output logic [TAG_W-1:0]         rd_tag
);

  // ----------------------------
  // Local parameters / checks
  // ----------------------------
  localparam int unsigned DEPTH = 1 << ADDR_W;

  // synthesis-time sanity checks (safe in simulation; many synth tools ignore)
  initial begin
    if (DATA_W % 8 != 0) begin
      $error("smem: DATA_W (%0d) must be a multiple of 8", DATA_W);
    end
    if (RD_LAT != 1) begin
      $warning("smem: RD_LAT=%0d requested, but this implementation is fixed to 1-cycle latency", RD_LAT);
    end
  end

  // ----------------------------
  // Memory array
  // ----------------------------
  logic [DATA_W-1:0] mem [0:DEPTH-1];

  // Always ready in this simple model
  assign cmd_ready = 1'b1;

  wire cmd_fire = cmd_valid & cmd_ready;

  // ----------------------------
  // Write logic (byte enables)
  // ----------------------------
  integer b;
  always_ff @(posedge clk) begin
    if (cmd_fire && rw) begin
      // Update only enabled bytes
      for (b = 0; b < DATA_W/8; b++) begin
        if (write_byten[b]) begin
          mem[addr][8*b +: 8] <= write_data[8*b +: 8];
        end
      end
    end
  end

  // ----------------------------
  // Read response pipeline (1-cycle) with skid/hold on backpressure
  // ----------------------------
  logic                  pending_valid;
  logic [DATA_W-1:0]      pending_data;
  logic [TAG_W-1:0]       pending_tag;

  // output regs
  always_ff @(posedge clk) begin
    if (rst) begin
      rd_valid      <= 1'b0;
      read_data     <= '0;
      rd_tag        <= '0;
      pending_valid <= 1'b0;
      pending_data  <= '0;
      pending_tag   <= '0;
    end else begin
      // If current output is valid and accepted, clear it
      if (rd_valid && outdata_ready) begin
        rd_valid <= 1'b0;
      end

      // Move pending -> output if output is free
      if (!rd_valid && pending_valid) begin
        rd_valid     <= 1'b1;
        read_data    <= pending_data;
        rd_tag       <= pending_tag;
        pending_valid<= 1'b0;
      end

      // Capture a new read request result into either output (if free)
      // or pending (if output busy). Read data is returned 1 cycle after cmd_fire.
      //
      // So we first register "read request" info, then on next cycle sample mem.
    end
  end

  // Register the read request (address/tag) on cmd_fire for reads
  logic                 rdreq_d;
  logic [ADDR_W-1:0]     rdaddr_d;
  logic [TAG_W-1:0]      rdtag_d;

  always_ff @(posedge clk) begin
    if (rst) begin
      rdreq_d  <= 1'b0;
      rdaddr_d <= '0;
      rdtag_d  <= '0;
    end else begin
      rdreq_d  <= cmd_fire && !rw;   // read accepted
      rdaddr_d <= addr;
      rdtag_d  <= tag;
    end
  end

  // On the cycle after rdreq_d asserted, produce the response.
  // If output occupied, stage into pending (1-deep).
  always_ff @(posedge clk) begin
    if (rst) begin
      // nothing
    end else begin
      if (rdreq_d) begin
        logic [DATA_W-1:0] rdata;
        rdata = mem[rdaddr_d];

        if (!rd_valid) begin
          rd_valid   <= 1'b1;
          read_data  <= rdata;
          rd_tag     <= rdtag_d;
        end else if (!pending_valid) begin
          pending_valid <= 1'b1;
          pending_data  <= rdata;
          pending_tag   <= rdtag_d;
        end else begin
          // If you can ever issue reads faster than the response channel consumes,
          // this 1-deep pending buffer can overflow. You can:
          //  (a) add cmd_ready backpressure, or
          //  (b) increase buffering.
          // For now, we flag it in simulation.
          $error("smem: response buffer overflow (rd_valid busy and pending_valid already set)");
        end
      end
    end
  end

  // If TAG_W==0, some tools dislike zero-width ports; this keeps things sane.
  generate
    if (TAG_W == 0) begin : gen_no_tag
      // rd_tag/tag ports exist but are zero width; nothing to do.
    end
  endgenerate

endmodule