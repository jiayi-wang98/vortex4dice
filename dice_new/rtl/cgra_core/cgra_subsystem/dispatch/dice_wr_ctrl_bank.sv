`include "bsg_fifo_1r1w_small.sv"
`include "DE_pkg.sv"

import DE_pkg::*;

// This is per bank, we_o already know which bank this will write to, so we_o only 
//care about the tid. Address conversion has already happened, but we_o are keeping the !!
module dice_wr_ctrl_bank #
(
      parameter WIDTH =  32
    , parameter DEPTH = 512
    , parameter ADDR_WIDTH = $clog2(DEPTH)
    , parameter BUF_ELS = 8
) 
(
      input logic         clk_i
    , input logic         reset_i

    // wr req from LDST and CGRA
    , input reg_wr_cmd   wr_cgra_i
    , input logic        cgra_valid_i
    , input reg_wr_cmd   wr_ldst_i
    , input logic        ldst_valid_i

    // forwarding for read
    , input reg_rd_cmd fw_req_i
    
    // stall from either buffer
    , output logic       stall_o
    // forwarding flags for each entry in buffer
    , output logic[7:0]         fw_hit_cgra_o
    , output logic[7:0]         fw_hit_ldst_o
    , output logic[WIDTH-1:0]   fw_data_o

    // signals out to register file
    , output logic[ADDR_WIDTH-1:0]   ws_o
    , output logic[WIDTH-1:0]        data_o
    , output logic                   we_o
);


// two buffers with forwarding flags for each entry. starting with 8 entries

  localparam BUF_DEPTH = 8;


  reg_wr_cmd cmd_lo;


// ---------------- CGRA buffer ----------------
  logic                  cgra_full,  cgra_empty;
  reg_wr_cmd             cgra_wb;
  logic                  cgra_wb_valid;
  logic [BUF_DEPTH-1:0]  cgra_fw_hit;
  logic [WIDTH-1:0]      cgra_fw_data_o;
  logic                  cgra_fw_valid;
  logic                  pop_cgra;

  `ifdef BUF_REG_CGRA

  reg_wr_buffer #(
          .WIDTH     (WIDTH)
        , .ADDR_WIDTH(ADDR_WIDTH)
        , .DEPTH     (BUF_DEPTH)
    ) u_cgra_buf (
          .clk_i          (clk_i)
        , .reset_i        (reset_i)
        , .wr_i           (wr_cgra_i)
        , .fw_req_i       (fw_req_i)
        , .pop_i          (pop_cgra)
        , .full_o         (cgra_full)
        , .empty_o        (cgra_empty)
        , .wb_addr_o      (cgra_wb_addr)
        , .wb_data_o      (cgra_wb_data)
        , .wb_valid_o     (cgra_wb_valid)
        , .fw_hit_o       (cgra_fw_hit)
        , .fw_data_o_o      (cgra_fw_data_o)
        , .fw_data_o_valid_o(cgra_fw_valid)
    );
 `else
  
  //TODO: implement single value write aribtration, a flip flop and a fw check maybe
  //
  
  reg_wr_single #(
        .WIDTH     (WIDTH)
      , .ADDR_WIDTH(ADDR_WIDTH)
  ) u_cgra_buf (
          .clk_i             (clk)
        , .reset_i           (reset_i)
        , .cgra_valid_i      (cgra_valid_i)
        , .cgra_ready_o      (cgra_full)
        , .cgra_wr_i         (wr_cgra_i)
        , .valid_o           (cgra_wb_valid)
        , .cmd_o             (cgra_wb)
        , .fw_req_i          (fw_req_i)
        , .fw_hit_o          (cgra_fw_hit[0])
        , .fw_data_o_o       (cgra_fw_data_o)
        , .fw_data_o_valid_o (cgra_fw_valid)
  );
  `endif //BUF_REG_CGRA 
  
  // ---------------- LDST buffer ----------------
  logic                 ldst_full,  ldst_empty;
  reg_wr_cmd             ldst_wb;
  logic                  ldst_wb_valid;
  logic [BUF_DEPTH-1:0]  ldst_fw_hit;
  logic [WIDTH-1:0]      ldst_fw_data_o;
  logic                  ldst_fw_valid;
  logic                  pop_ldst;

  reg_wr_buffer #(
          .WIDTH     (WIDTH)
        , .ADDR_WIDTH(ADDR_WIDTH)
        , .DEPTH     (BUF_DEPTH)
    ) u_ldst_buf (
          .clk_i          (clk_i)
        , .reset_i        (reset_i)
        , .wr_i           (wr_ldst_i)
        , .fw_req_i       (fw_req_i)
        , .pop_i          (pop_ldst)
        , .valid_i        (ldst_valid_i)
        , .full_o         (ldst_full)
        , .empty_o        (ldst_empty)
        , .cmd_o          (ldst_wb)
        , .wb_valid_o     (ldst_wb_valid)
        , .fw_hit_o       (ldst_fw_hit)
        , .fw_data_o_o      (ldst_fw_data_o)
        , .fw_data_o_valid_o(ldst_fw_valid)
    );

  assign stall_o = cgra_full || ldst_full;

  assign fw_hit_ldst_o = ldst_fw_hit;
  assign fw_hit_cgra_o = cgra_fw_hit;

  //fw data

  always_comb begin
    if (cgra_fw_valid) begin
      fw_data_o = cgra_fw_data_o;
    end else if (ldst_fw_valid) begin
      fw_data_o = ldst_fw_data_o;
    end else begin
      fw_data_o = '0;
    end
  end
  
  // wb arbitration

  always_comb begin
    cmd_lo = cgra_wb_valid ? cgra_wb : ldst_wb;
    pop_ldst = !cgra_wb_valid;

    data_o = cmd.data;
    we_o = cmd.we;
    ws_o = cmd.tid;
  end    


endmodule

