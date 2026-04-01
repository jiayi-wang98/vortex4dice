// =============================================================================
// FILE: tcu_pkg.sv
// =============================================================================
// DESCRIPTION:
//   UVM package for the Temporal Coalescing Unit (TCU) testbench. This package
//   centralizes all type, component, sequence, and test includes to provide a
//   single import point for the verification environment.
//
// USAGE:
//   Import the package in the top-level testbench or any UVM component:
//     import tcu_pkg::*;
// =============================================================================
package tcu_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  //------------------------------------------
  // Transaction Items
  //------------------------------------------
  `include "tcu_seq_item.svh"
  `include "tcu_out_item.svh"

  //------------------------------------------
  // Agent Components
  //------------------------------------------
  `include "tcu_driver.svh"
  `include "tcu_monitor.svh"
  `include "tcu_sequencer.svh"
  `include "tcu_agent.svh"

  //------------------------------------------
  // Sequences
  //------------------------------------------
  `include "tcu_random_seq.svh"

  //------------------------------------------
  // Environment Components
  //------------------------------------------
  `include "tcu_scoreboard.svh"
  `include "tcu_env.svh"

  //------------------------------------------
  // Tests
  //------------------------------------------
  `include "tcu_base_test.svh"

endpackage
