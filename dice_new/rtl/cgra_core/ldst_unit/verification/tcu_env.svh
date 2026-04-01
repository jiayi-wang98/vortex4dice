// =============================================================================
// FILE: tcu_env.svh
// =============================================================================
// DESCRIPTION:
//   UVM environment for the TCU testbench. Instantiates the agent and
//   scoreboard and connects analysis ports.
// =============================================================================
// =============================================================================
// ENVIRONMENT
// =============================================================================
class tcu_env extends uvm_env;
  `uvm_component_utils(tcu_env)

  // Environment sub-components
  tcu_agent      agt;
  tcu_scoreboard scb;

  function new(string name = "tcu_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create agent and scoreboard
    agt = tcu_agent::type_id::create("agt", this);
    scb = tcu_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect monitor analysis ports to scoreboard imports
    agt.mon.in_ap.connect(scb.in_imp);
    agt.mon.out_ap.connect(scb.out_imp);
  endfunction

endclass
