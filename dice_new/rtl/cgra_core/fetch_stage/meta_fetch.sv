`include "VX_define.vh"

module meta_fetch #(
    parameter int TAG_WIDTH = 48
) (
    input logic clk,
    input logic rst,

    // From CS/FDR barrier
    input logic schedule_valid,
    input logic [dice_pkg::DICE_ADDR_WIDTH-1:0] fdr_next_pc,
    input logic [dice_frontend_pkg::EBLOCK_ID_WIDTH-1:0] schedule_eblock_id,
    output logic schedule_ready,

    // Request channel to cache
    VX_mem_bus_if.master meta_fetch_bus_if,

    // To decoder
    output dice_frontend_pkg::pgraph_meta_t outgoing_meta,
    output logic meta_valid,

    // From stage barrier
    input logic fire_eblock
);
  localparam PAD_WIDTH = TAG_WIDTH - dice_frontend_pkg::EBLOCK_ID_WIDTH;

  // FSM states
  typedef enum logic [1:0] {
    S_READY     = 2'b00,  // fetcher is ready for a new pc
    S_REQ_VAL   = 2'b01,
    S_WAIT_RESP = 2'b10,  // waiting for response from cache
    S_HOLD_DATA = 2'b11   //waits for decoder to consume meta
  } meta_fetch_state_e;

  meta_fetch_state_e state_q, state_d;
  logic meta_valid_q;
  logic [dice_frontend_pkg::EBLOCK_ID_WIDTH-1:0] eblock_id_q;

  logic rsp_fire, req_fire;
  assign rsp_fire = meta_fetch_bus_if.rsp_valid && meta_fetch_bus_if.rsp_ready;
  assign req_fire = meta_fetch_bus_if.req_valid && meta_fetch_bus_if.req_ready;

  //DIRECTLY FROM VORTEX======================================================
  logic [VX_gpu_pkg::ICACHE_ADDR_WIDTH-1:0] meta_cache_req_addr_q, meta_cache_req_addr_d;
  localparam ADDR_SHIFT = $clog2(
      VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8
  );  // Should calculate shift based on data width (bytes)
  assign meta_cache_req_addr_d = fdr_next_pc[ADDR_SHIFT+:VX_gpu_pkg::ICACHE_ADDR_WIDTH];
  // 4-byte aligned addresses
  //DIRECTLY FROM VORTEX======================================================


  always_comb begin
    schedule_ready = 1'b0;
    state_d = state_q;

    unique case (state_q)
      S_READY: begin
        schedule_ready = 1'b1;
        if (schedule_valid) begin
          state_d = S_REQ_VAL;
        end
      end
      S_REQ_VAL: begin
        if (req_fire) state_d = S_WAIT_RESP;
      end
      S_WAIT_RESP: begin
        if (rsp_fire) begin
          state_d = S_HOLD_DATA;
        end
      end
      S_HOLD_DATA: begin
        if (fire_eblock) state_d = S_READY;
      end
      default: state_d = S_READY;
    endcase
  end


  always_ff @(posedge clk) begin
    if (rst) begin
      state_q <= S_READY;
      meta_valid_q <= 1'b0;
      meta_cache_req_addr_q <= '0;
      outgoing_meta <= '0;
      eblock_id_q <= '0;
    end else begin
      state_q <= state_d;
      if (state_q == S_READY && schedule_valid && schedule_ready) begin
        meta_cache_req_addr_q <= meta_cache_req_addr_d;
        eblock_id_q <= schedule_eblock_id;
      end
      if (rsp_fire) begin
        outgoing_meta <= dice_frontend_pkg::pgraph_meta_t'(meta_fetch_bus_if.rsp_data.data);
        meta_valid_q  <= 1'b1;
      end
      if (fire_eblock) begin
        meta_valid_q <= 1'b0;
      end
    end
  end


  //============= UNUSED VORTEX CACHE FEATURES =================//
  assign meta_fetch_bus_if.req_data.flags  = '0;  //misc / not used
  assign meta_fetch_bus_if.req_data.rw     = 0;  //read/write bit
  assign meta_fetch_bus_if.req_data.byteen = '1;  //byte mask (for stores)
  assign meta_fetch_bus_if.req_data.data   = '0;  //write payload

  //Pad unused part of VORTEX tag with zeros
  //Logic is less complicated since there is only one cta
  //in fdr at once as opposed to vortexs large # of warps
  assign meta_fetch_bus_if.req_data.tag    = {{PAD_WIDTH{1'b0}}, eblock_id_q};

  //============ MISC ASSIGNS ======================//
  assign meta_fetch_bus_if.req_data.addr   = meta_cache_req_addr_q;
  assign meta_fetch_bus_if.req_valid       = (state_q == S_REQ_VAL);
  assign meta_fetch_bus_if.rsp_ready       = (state_q == S_WAIT_RESP);
  assign meta_valid                        = meta_valid_q;
endmodule
