`timescale 1ns/1ps

/* Intital frontend package:
This will likely need to be changed when i learn more about verilog header files,
I have not researched them yet but am initializing this file for the meta_fetch module
*/


package frontend_pkg;
  // =========================================================
  // Type definitions
  // =========================================================
    typedef struct packed {
    logic [31:0]     bitstream_addr;     // 32-bit: Address of the CGRA configuration bitstream
    logic [7:0]      bitstream_length;   // 8-bit: Bitstream size in bytes
    logic [1:0]      unrolling_factor;   // 2-bit: Max thread unrolling factor
    logic [7:0]      lat;                // 8-bit: CGRA fabric latency for the p-graph
    logic [33:0]     in_regs;            // 34-bit: Input registers bitmap
    logic [33:0]     out_regs;           // 34-bit: Direct output registers bitmap
    logic [7:0][5:0] ld_dest_regs;       // 8×6-bit: Destination register indexes for memory loads
    logic [2:0]      num_stores;         // 3-bit: Number of stores per thread
    logic [31:0]     branch_meta;        // 32-bit: Branch/Jump metadata
    logic            barrier;            // 1-bit: Barrier indicator (must wait for previous blocks)
    logic            parameter_load;     // 1-bit: True if p-graph only loads constants
    } pgraph_meta_t;
    
endpackage
