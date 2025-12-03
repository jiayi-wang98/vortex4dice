`include "bsg_fifo_1r1w_small.sv"
`include "DE_pkg.sv"

import DE_pkg::*;

// This is per bank, we already know which bank this will write to, so we only 
//care about the tid. Address conversion has already happened, but we are keeping the !!
module dice_wr_ctrl_bank #
(
      parameter WIDTH =  32
    , parameter DEPTH = 512
    , parameter ADDR_WIDTH = $clog2(DEPTH)
    , parameter BUF_ELS = 8
) 
(
      input logic         clk
    , input logic         rstn

    // wr req from LDST and CGRA
    , input reg_wr_cmd   wr_cgra
    , input reg_wr_cmd   wr_ldst

    // forwarding for read
    , input reg_rd_cmd fw_req
    
    // stall from either buffer
    , output logic       stall
    // forwarding flags for each entry in buffer
    , output logic[7:0]         fw_hit_cgra
    , output logic[7:0]         fw_hit_ldst
    , output logic[WIDTH-1:0]   fw_data

    // signals out to register file
    , output logic[ADDR_WIDTH-1:0]   ws
    , output logic[WIDTH-1:0]        data
    , output logic                   we
);


// two buffers with forwarding flags for each entry. starting with 8 entries

  localparam BUF_DEPTH = 8;



// ---------------- CGRA buffer ----------------
  logic                 cgra_full,  cgra_empty;
  logic [ADDR_WIDTH-1:0] cgra_wb_addr;
  logic [WIDTH-1:0]      cgra_wb_data;
  logic                  cgra_wb_valid;
  logic [BUF_DEPTH-1:0]  cgra_fw_hit;
  logic [WIDTH-1:0]      cgra_fw_data;
  logic                  cgra_fw_valid;
  logic                  pop_cgra;

  `ifdef BUF_REG_CGRA

  reg_wr_buffer #(
          .WIDTH     (WIDTH)
        , .ADDR_WIDTH(ADDR_WIDTH)
        , .DEPTH     (BUF_DEPTH)
    ) u_cgra_buf (
          .clk_i          (clk)
        , .reset_i        (reset)
        , .wr_i           (wr_cgra)
        , .fw_req_i       (fw_req)
        , .pop_i          (pop_cgra)
        , .full_o         (cgra_full)
        , .empty_o        (cgra_empty)
        , .wb_addr_o      (cgra_wb_addr)
        , .wb_data_o      (cgra_wb_data)
        , .wb_valid_o     (cgra_wb_valid)
        , .fw_hit_o       (cgra_fw_hit)
        , .fw_data_o      (cgra_fw_data)
        , .fw_data_valid_o(cgra_fw_valid)
    );
 `else
  
  //TODO: implement single value write aribtration, a flip flop and a fw check maybe
  //
  
  reg_wr_single_entry #(
        .WIDTH     (WIDTH)
      , .ADDR_WIDTH(ADDR_WIDTH)
      , .DEPTH     (BUF_DEPTH)
  ) u_cgra_buf (
          .clk_i          (clk)
        , .rstn_i         (rst_n)
        , .wr_i           (wr_cgra)
        , .fw_req_i       (fw_req)
        , .pop_i          (pop_cgra)
        , .full_o         (cgra_full)
        , .empty_o        (cgra_empty)
        , .wb_addr_o      (cgra_wb_addr)
        , .wb_data_o      (cgra_wb_data)
        , .wb_valid_o     (cgra_wb_valid)
        , .fw_hit_o       (cgra_fw_hit[0])
        , .fw_data_o      (cgra_fw_data)
        , .fw_data_valid_o(cgra_fw_valid)
  );
  `endif //BUF_REG_CGRA 
  
  // ---------------- LDST buffer ----------------
  logic                 ldst_full,  ldst_empty;
  logic [ADDR_WIDTH-1:0] ldst_wb_addr;
  logic [WIDTH-1:0]      ldst_wb_data;
  logic                  ldst_wb_valid;
  logic [BUF_DEPTH-1:0]  ldst_fw_hit;
  logic [WIDTH-1:0]      ldst_fw_data;
  logic                  ldst_fw_valid;
  logic                  pop_ldst;

  reg_wr_buffer #(
          .WIDTH     (WIDTH)
        , .ADDR_WIDTH(ADDR_WIDTH)
        , .DEPTH     (BUF_DEPTH)
    ) u_ldst_buf (
          .clk_i          (clk)
        , .reset_i        (reset)
        , .wr_i           (wr_ldst)
        , .fw_req_i       (fw_req)
        , .pop_i          (pop_ldst)
        , .full_o         (ldst_full)
        , .empty_o        (ldst_empty)
        , .wb_addr_o      (ldst_wb_addr)
        , .wb_data_o      (ldst_wb_data)
        , .wb_valid_o     (ldst_wb_valid)
        , .fw_hit_o       (ldst_fw_hit)
        , .fw_data_o      (ldst_fw_data)
        , .fw_data_valid_o(ldst_fw_valid)
    );

  assign stall = cgra_full || ldst_full;

  assign fw_hit_ldst = ldst_fw_hit;
  assign fw_hit_cgra = cgra_fw_hit;

  //fw data

  always_comb begin
    if (cgra_fw_valid) begin
      fw_data = cgra_fw_data;
    end else if (ldst_fw_valid) begin
      fw_data = ldst_fw_data;
    end else begin
      fw_data = '0;
    end
  end
  
  // wb arbitration

  always_comb begin
    ws = '0;
    data = '0;
    we = '0;
    pop_cgra = '0;
    pop_ldst = '0;

    if(cgra_wb_valid) begin
      ws = cgra_wb_addr;
      data = cgra_wb_data;
      we = 1'b1;
      pop_cgra = 1'b1;
    end
    else begin
      ws = ldst_wb_addr;
      data = ldst_wb_data;
      we = 1'b1;
      pop_ldst = 1'b1;
    end
  end    
endmodule

