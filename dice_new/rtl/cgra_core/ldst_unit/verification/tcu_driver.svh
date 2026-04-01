// =============================================================================
// FILE: tcu_driver.svh
// =============================================================================
// DESCRIPTION:
//   UVM driver for the TCU input command interface. Converts sequence items
//   into pin-level activity and performs valid/ready handshaking with the DUT.
// =============================================================================
// =============================================================================
// DRIVER - Converts transactions to pin activity
// =============================================================================
class tcu_driver extends uvm_driver #(tcu_seq_item);
  `uvm_component_utils(tcu_driver)

  // Virtual interface for driving the DUT pins
  virtual tcu_if.driver_mp vif;

  function new(string name = "tcu_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Retrieve the virtual interface from the config_db
    if (!uvm_config_db#(virtual tcu_if.driver_mp)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not set for tcu_driver")
    end
  endfunction

  task run_phase(uvm_phase phase);
    tcu_seq_item tr;

    `uvm_info("DRIVER", "Driver run_phase started", UVM_LOW)

    // Small delay to avoid time-0 race conditions with testbench initial blocks
    #1ns;
    $display("[DRIVER DEBUG] Time=%0t, rst_n=%0b", $realtime, vif.rst_n);
    `uvm_info("DRIVER", $sformatf("After 1ns delay (time=%0t), rst_n=%0b", $realtime, vif.rst_n), UVM_LOW)

    // Initialize all driven outputs to idle values
    vif.incmd_valid      <= 0;
    vif.incmd_block_id   <= 0;
    vif.incmd_tid        <= 0;
    vif.incmd_write_enable <= 0;
    vif.incmd_write_data <= 0;
    vif.incmd_write_mask <= 8'hFF;
    vif.incmd_address    <= 0;
    vif.incmd_size       <= 0;
    vif.incmd_ld_dest_reg <= 0;
    vif.outcmd_ready     <= 1;

    // Wait for a clock edge to ensure all signals are stable before driving
    $display("[DRIVER DEBUG] Before waiting for clk: Time=%0t, clk=%0b", $realtime, vif.clk);
    fork
      begin
        @(posedge vif.clk);
        $display("[DRIVER DEBUG] After posedge clk: Time=%0t, rst_n=%0b", $realtime, vif.rst_n);
      end
      begin
        #1000ns;
        $display("[DRIVER DEBUG] TIMEOUT! Clock never toggled! Time=%0t, clk=%0b", $realtime, vif.clk);
        `uvm_fatal("DRIVER", "Clock timeout - clock is not running!")
      end
    join_any
    disable fork;
    `uvm_info("DRIVER", $sformatf("After clock edge (time=%0t), rst_n=%0b", $realtime, vif.rst_n), UVM_LOW)

    // Wait for reset to be released - handle if already released or not
    if (vif.rst_n === 0) begin
      `uvm_info("DRIVER", "Waiting for reset release (posedge rst_n)...", UVM_LOW)
      @(posedge vif.rst_n);
    end else begin
      `uvm_info("DRIVER", "Reset already released, skipping wait", UVM_LOW)
    end
    `uvm_info("DRIVER", "Reset released, waiting for DUT initialization...", UVM_LOW)
    repeat(10) @(posedge vif.clk);
    `uvm_info("DRIVER", "Starting transaction processing", UVM_LOW)

    // Main driver loop: pull items from sequencer and drive them
    forever begin
      seq_item_port.get_next_item(tr);
      `uvm_info("DRIVER", $sformatf("Driving: %s", tr.convert2string()), UVM_MEDIUM)
      drive_transaction(tr);
      seq_item_port.item_done();
    end
  endtask

  // Drive a single transaction using a valid/ready handshake
  task drive_transaction(tcu_seq_item tr);
    int timeout_counter;
    timeout_counter = 0;

    @(posedge vif.clk);

    vif.incmd_block_id     <= tr.block_id;
    vif.incmd_tid          <= tr.tid;
    vif.incmd_write_enable <= tr.write_enable;
    vif.incmd_write_data   <= tr.write_data;
    vif.incmd_write_mask   <= tr.write_mask;
    vif.incmd_address      <= tr.address;
    vif.incmd_size         <= tr.size;
    vif.incmd_ld_dest_reg  <= tr.ld_dest_reg;
    vif.incmd_valid        <= 1'b1;

    `uvm_info("DRIVER", "Waiting for incmd_ready handshake...", UVM_HIGH)

    // Wait for handshake with timeout
    do begin
      @(posedge vif.clk);
      timeout_counter++;

      if (timeout_counter > 1000) begin
        `uvm_fatal("DRIVER", $sformatf("TIMEOUT waiting for incmd_ready! incmd_ready=%0b, Transaction: %s",
                   vif.incmd_ready, tr.convert2string()))
      end

      if (timeout_counter % 100 == 0) begin
        `uvm_info("DRIVER", $sformatf("Still waiting for incmd_ready (cycle %0d), incmd_ready=%0b",
                  timeout_counter, vif.incmd_ready), UVM_MEDIUM)
      end
    end while (!vif.incmd_ready);

    `uvm_info("DRIVER", $sformatf("Handshake complete after %0d cycles", timeout_counter), UVM_HIGH)
    vif.incmd_valid <= 1'b0;
  endtask

endclass
