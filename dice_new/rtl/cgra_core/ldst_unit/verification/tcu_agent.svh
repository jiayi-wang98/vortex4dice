// =============================================================================
// FILE: tcu_agent.svh
// =============================================================================
// DESCRIPTION:
//   UVM agent encapsulating the driver, monitor, and sequencer for the TCU
//   interface. Supports active or passive operation via is_active flag.
// =============================================================================
// =============================================================================
// AGENT - Contains driver, monitor, sequencer
// =============================================================================
class tcu_agent extends uvm_agent;
  `uvm_component_utils(tcu_agent)

  // Agent sub-components
  tcu_driver    drv;
  tcu_monitor   mon;
  tcu_sequencer sqr;
  
  // Active agent drives stimulus; passive agent only monitors
  bit is_active = 1;

  function new(string name = "tcu_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Always create monitor; create driver/sequencer only if active
    mon = tcu_monitor::type_id::create("mon", this);
    if (is_active) begin
      drv = tcu_driver::type_id::create("drv", this);
      sqr = tcu_sequencer::type_id::create("sqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect sequencer to driver when active
    if (is_active) begin
      drv.seq_item_port.connect(sqr.seq_item_export);
    end
  endfunction

endclass
