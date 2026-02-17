// `timescale 1ns/1ps
`include "dice_define.vh"

module tb_dice_core;
  import dice_pkg::*;
  import dice_frontend_pkg::*;
  import VX_gpu_pkg::*;

  // =========================================================================
  // Parameters
  // =========================================================================
  localparam int TimeoutCycles = 1000;
  localparam int ClkPeriod     = 10;

  // =========================================================================
  // Signals
  // =========================================================================
  logic clk;
  logic reset;


  // =========================================================================
  // Interfaces
  // =========================================================================
  cta_dispatch_if cta_dispatch_if_inst();
  cta_complete_if cta_complete_if_inst();

  VX_mem_bus_if #(
      .DATA_SIZE(256), //change
      .TAG_WIDTH(DICE_ADDR_WIDTH)
  ) metacache_mem_if ();

  VX_mem_bus_if #(
      .DATA_SIZE(512), //change
      .TAG_WIDTH(DICE_ADDR_WIDTH)
  ) bitstream_cache_mem_if ();

  // =========================================================================
  // Randomization Class - MAYBE MOVE THIS TO A SEPARATE FILE
  // =========================================================================
  class CtaGenerator;
    rand dice_cta_desc_t desc;

    constraint c_grid_size {
      desc.kernel_desc.grid_size.x inside {[1:4]};
      desc.kernel_desc.grid_size.y inside {[1:4]};
      desc.kernel_desc.grid_size.z inside {[1:4]};
    }

    constraint c_cta_size {
      desc.kernel_desc.cta_size.x inside {[1:32]};
      desc.kernel_desc.cta_size.y inside {[1:4]};
      desc.kernel_desc.cta_size.z inside {[1:3]};
    }

    constraint c_cta_id {
      desc.cta_id.x < desc.kernel_desc.grid_size.x;
      desc.cta_id.y < desc.kernel_desc.grid_size.y;
      desc.cta_id.z < desc.kernel_desc.grid_size.z;
    }

    constraint c_params {
      desc.kernel_desc.kernel_id inside {[0:16]};
      desc.kernel_desc.smem_per_cta inside {[0:16]};
      desc.kernel_desc.start_pc == 32'h1000; // So that we can get correct metadata
      desc.kernel_desc.arg_ptr == 32'h2000;
    }
  endclass

  class MetadataGenerator;
    rand pgraph_meta_t metadata;

    constraint base_metadata {
      metadata.bitstream_length == 512;
      metadata.num_stores inside {[0:3]};
      metadata.lat inside {[1:10]};
      metadata.unrolling_factor == 0;
      metadata.barrier == 0;
      metadata.parameter_load == 0;
      metadata.bitstream_addr[0:$clog2(DICE_METADATA_WIDTH)-1] == '0; // MAY BE WRONG
    }

    constraint branch_metadata {
      metadata.branch_meta.branch_ena == 0;
      // metadata.branch_meta.branch_ena dist {0:=80, 1:=20};
      metadata.branch_meta.branch_uni dist {0:=50, 1:=50};
      metadata.branch_meta.branch_pred_reg inside {[0:7]};
      metadata.branch_meta.branch_jump_target_offset inside {[1:3]};
      metadata.branch_meta.branch_reconv_offset inside {[1:3]};
    }
  endclass

  // =========================================================================
  // Memory Instantiation
  // =========================================================================
   VX_local_mem #(
    .SIZE      (1 << 26),
    .NUM_REQS  (1),
    .NUM_BANKS (1),
    .ADDR_WIDTH(19), //gonna have to figure out how to make this work
    .WORD_SIZE (256),
    .TAG_WIDTH (DICE_ADDR_WIDTH),
    .OUT_BUF   (0)
   ) u_meta_mem (
      .clk        (clk),
      .reset      (reset),
      .mem_bus_if (metacache_mem_if)
   );

   VX_local_mem #(
    .SIZE      (1 << 26),
    .NUM_REQS  (1),
    .NUM_BANKS (1),
    .ADDR_WIDTH(19),
    .WORD_SIZE (512),
    .TAG_WIDTH (DICE_ADDR_WIDTH),
    .OUT_BUF   (0)
   ) u_bitstream_mem (
      .clk        (clk),
      .reset      (reset),
      .mem_bus_if (bitstream_cache_mem_if)
   );


  // =========================================================================
  // Timeout Counter
  // =========================================================================
  int cycle_count;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) cycle_count <= 0;
    else begin
      cycle_count <= cycle_count + 1;
      if (cycle_count >= TimeoutCycles) begin
         $error("TIMEOUT");
         $finish;
      end
    end
  end

  // =========================================================================
  // DUT Instantiation
  // =========================================================================
  dice_core u_dut (
      .clk_i                   (clk),
      .rst_i                   (reset),
      .cta_dispatch_if_inst    (cta_dispatch_if_inst),
      .cta_complete_if_inst    (cta_complete_if_inst),
      .metacache_mem_if        (metacache_mem_if),
      .bitstream_cache_mem_if  (bitstream_cache_mem_if)
  );

  // =========================================================================
  // Clock Generation
  // =========================================================================
  initial begin
    clk = 1'b0;
    forever #(ClkPeriod / 2) clk = ~clk;
  end

  // =========================================================================
  // Helper Tasks
  // =========================================================================

  //Initializes inputs to the DUT
  task automatic init_inputs();
    cta_dispatch_if_inst.valid = 1'b0;
    cta_dispatch_if_inst.data  = '0;
    cta_complete_if_inst.ready = 1'b1;
  endtask

  //Resets the DUT
  task automatic reset_dut();
    reset = 1'b1;
    repeat (5) @(posedge clk);
    reset = 1'b0;
  endtask

  //Dispatches CTA into the core with specified description
  task automatic dispatch_cta(input dice_cta_desc_t desc);
    cta_dispatch_if_inst.valid = 1'b1;
    cta_dispatch_if_inst.data  = desc;

    do begin
      @(posedge clk);
    end while (!cta_dispatch_if_inst.ready);

    cta_dispatch_if_inst.valid = 1'b0;
  endtask

  // Task to generate and dispatch random CTA
  task automatic dispatch_random_cta();
    CtaGenerator gen;
    gen = new();

    if(gen.randomize()) begin
      $display("Dispatching CTA: KernelID=%0d, Grid=(%0d,%0d,%0d), CTA_ID=(%0d,%0d,%0d)",
                gen.desc.kernel_desc.kernel_id,
                gen.desc.kernel_desc.grid_size.x, gen.desc.kernel_desc.grid_size.y, gen.desc.kernel_desc.grid_size.z,
                gen.desc.cta_id.x, gen.desc.cta_id.y, gen.desc.cta_id.z);
      dispatch_cta(gen.desc);
    end else begin
      $error("Failed to randomize CTA descriptor");
    end
  endtask

  // CREATE TASK TO ADD METADATA/BITSTREAM TO MEMORIES


// Stimulus
  initial begin
    $display("dice_core random testbench");
    init_inputs();
    reset_dut();

    dispatch_random_cta();
    repeat (100) @(posedge clk);

    $display("TB Done");
    $finish;
  end

`ifdef FSDB
  initial begin
    $fsdbDumpfile("tb_dice_core.fsdb");
    $fsdbDumpvars(0, "+struct");
  end
`endif

endmodule
