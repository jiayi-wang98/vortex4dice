module tb_active_cta_table;

    // Parameters
    parameter MAX_NUM_CTA = 4;
    parameter CTA_INDEX_WIDTH = $clog2(MAX_NUM_CTA);
    parameter THREAD_WIDTH = 256;
    parameter CLK_PERIOD = 2.5; // 400MHz = 2.5ns period
    
    // Clock and reset
    logic clk;
    logic rst_n;
    
    // DUT signals
    logic pop_valid;
    logic [CTA_INDEX_WIDTH-1:0] pop_hw_cta_id;
    
    logic add_valid;
    logic [15:0] add_cta_id_x;
    logic [15:0] add_cta_id_y;
    logic [15:0] add_cta_id_z;
    logic [15:0] add_grid_size_x;
    logic [15:0] add_grid_size_y;
    logic [15:0] add_grid_size_z;
    logic [10:0] add_cta_size_x;
    logic [10:0] add_cta_size_y;
    logic [10:0] add_cta_size_z;
    logic [10:0] add_cta_size;
    logic [15:0] add_kernel_id;
    logic add_ready;
    
    logic out_valid;
    logic [15:0] out_cta_id_x;
    logic [15:0] out_cta_id_y;
    logic [15:0] out_cta_id_z;
    logic [10:0] out_cta_size;
    logic [15:0] out_kernel_id;
    logic out_ready;
    
    logic [MAX_NUM_CTA-1:0] cta_valid;
    logic [MAX_NUM_CTA-1:0][15:0] cta_id_x;
    logic [MAX_NUM_CTA-1:0][15:0] cta_id_y;
    logic [MAX_NUM_CTA-1:0][15:0] cta_id_z;
    logic [MAX_NUM_CTA-1:0][15:0] grid_size_x;
    logic [MAX_NUM_CTA-1:0][15:0] grid_size_y;
    logic [MAX_NUM_CTA-1:0][15:0] grid_size_z;
    logic [MAX_NUM_CTA-1:0][10:0] cta_size_x;
    logic [MAX_NUM_CTA-1:0][10:0] cta_size_y;
    logic [MAX_NUM_CTA-1:0][10:0] cta_size_z;
    logic [MAX_NUM_CTA-1:0][10:0] cta_size;
    logic [MAX_NUM_CTA-1:0][15:0] kernel_id;
    
    logic full;
    logic [CTA_INDEX_WIDTH-1:0] next_empty_cta_index;
    
    // Test control
    int test_count;
    int pass_count;
    int fail_count;
    
    // CTA data structure for verification
    typedef struct packed {
        logic [15:0] cta_id_x;
        logic [15:0] cta_id_y;
        logic [15:0] cta_id_z;
        logic [15:0] grid_size_x;
        logic [15:0] grid_size_y;
        logic [15:0] grid_size_z;
        logic [10:0] cta_size_x;
        logic [10:0] cta_size_y;
        logic [10:0] cta_size_z;
        logic [10:0] cta_size; // New
        logic [15:0] kernel_id;
    } cta_data_t;
    
    // Test data array
    cta_data_t test_ctas [0:4]; // Expanded to 5 to test multi-entry
    
    // DUT instantiation
    active_cta_table #(
        .MAX_NUM_CTA(MAX_NUM_CTA),
        .THREAD_WIDTH(THREAD_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .pop_valid(pop_valid),
        .pop_hw_cta_id(pop_hw_cta_id),
        
        .add_valid(add_valid),
        .add_cta_id_x(add_cta_id_x),
        .add_cta_id_y(add_cta_id_y),
        .add_cta_id_z(add_cta_id_z),
        .add_grid_size_x(add_grid_size_x),
        .add_grid_size_y(add_grid_size_y),
        .add_grid_size_z(add_grid_size_z),
        .add_cta_size_x(add_cta_size_x),
        .add_cta_size_y(add_cta_size_y),
        .add_cta_size_z(add_cta_size_z),
        .add_cta_size(add_cta_size), // New
        .add_kernel_id(add_kernel_id),
        .add_ready(add_ready),
        
        .out_valid(out_valid),
        .out_cta_id_x(out_cta_id_x),
        .out_cta_id_y(out_cta_id_y),
        .out_cta_id_z(out_cta_id_z),
        .out_cta_size(out_cta_size), // New
        .out_kernel_id(out_kernel_id),
        .out_ready(out_ready),
        
        .cta_valid(cta_valid),
        .cta_id_x(cta_id_x),
        .cta_id_y(cta_id_y),
        .cta_id_z(cta_id_z),
        .grid_size_x(grid_size_x),
        .grid_size_y(grid_size_y),
        .grid_size_z(grid_size_z),
        .cta_size_x(cta_size_x),
        .cta_size_y(cta_size_y),
        .cta_size_z(cta_size_z),
        .cta_size(cta_size), // New
        .kernel_id(kernel_id),
        .full(full),
        .next_empty_cta_index(next_empty_cta_index)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Initialize test data
    initial begin
        // Single entry CTAs (256 threads)
        test_ctas[0] = '{16'h0001, 16'h0000, 16'h0000, 16'h0010, 16'h0001, 16'h0001, 11'h100, 11'h001, 11'h001, 11'h100, 16'hA001}; // 256x1x1 = 256
        test_ctas[1] = '{16'h0002, 16'h0000, 16'h0000, 16'h0010, 16'h0001, 16'h0001, 11'h080, 11'h002, 11'h001, 11'h100, 16'hA002}; // 128x2x1 = 256
        test_ctas[2] = '{16'h0003, 16'h0000, 16'h0000, 16'h0010, 16'h0001, 16'h0001, 11'h040, 11'h004, 11'h001, 11'h100, 16'hA003}; // 64x4x1 = 256
        test_ctas[3] = '{16'h0004, 16'h0000, 16'h0000, 16'h0010, 16'h0001, 16'h0001, 11'h020, 11'h008, 11'h001, 11'h100, 16'hA004}; // 32x8x1 = 256
        
        // Multi-entry CTA (512 threads, 2 entries)
        test_ctas[4] = '{16'h0005, 16'h0000, 16'h0000, 16'h0010, 16'h0001, 16'h0001, 11'h080, 11'h004, 11'h001, 11'h200, 16'hA005}; // 128x4x1 = 512
    end
    
    // Task to initialize signals
    task init_signals();
        pop_valid = 0;
        pop_hw_cta_id = 0;
        add_valid = 0;
        add_cta_id_x = 0;
        add_cta_id_y = 0;
        add_cta_id_z = 0;
        add_grid_size_x = 0;
        add_grid_size_y = 0;
        add_grid_size_z = 0;
        add_cta_size_x = 0;
        add_cta_size_y = 0;
        add_cta_size_z = 0;
        add_cta_size = 0;
        add_kernel_id = 0;
        out_ready = 1; // Default ready to receive output
    endtask
    
    // Task to add a CTA entry
    task add_cta(input int index);
        @(negedge clk);
        add_valid = 1;
        add_cta_id_x = test_ctas[index].cta_id_x;
        add_cta_id_y = test_ctas[index].cta_id_y;
        add_cta_id_z = test_ctas[index].cta_id_z;
        add_grid_size_x = test_ctas[index].grid_size_x;
        add_grid_size_y = test_ctas[index].grid_size_y;
        add_grid_size_z = test_ctas[index].grid_size_z;
        add_cta_size_x = test_ctas[index].cta_size_x;
        add_cta_size_y = test_ctas[index].cta_size_y;
        add_cta_size_z = test_ctas[index].cta_size_z;
        add_kernel_id = test_ctas[index].kernel_id;
        add_cta_size = test_ctas[index].cta_size;
        
        wait (add_ready);
        @(negedge clk);
        add_valid = 0;
        $display("Added CTA %0d: ID=(%0d,%0d,%0d) Size=%0d Kernel=%0h", index, 
                 test_ctas[index].cta_id_x, test_ctas[index].cta_id_y, 
                 test_ctas[index].cta_id_z, test_ctas[index].cta_size, test_ctas[index].kernel_id);
    endtask
    
    // Task to pop a CTA entry
    task pop_cta(input logic [CTA_INDEX_WIDTH-1:0] cta_id);
        @(negedge clk);
        pop_valid = 1;
        pop_hw_cta_id = cta_id;
        @(negedge clk);
        pop_valid = 0;
        $display("Popped CTA %0d", cta_id);
    endtask
    
    // Task to check output
    task check_output(input cta_data_t expected);
        automatic logic match;
        
        wait (out_valid);
        @(negedge clk);
        
        match = (out_cta_id_x == expected.cta_id_x) &&
                (out_cta_id_y == expected.cta_id_y) &&
                (out_cta_id_z == expected.cta_id_z) &&
                (out_cta_size == expected.cta_size) &&
                (out_kernel_id == expected.kernel_id);
        
        if (match) begin
            $display("✓ OUTPUT MATCH: ID=(%0d,%0d,%0d) Size=%0d Kernel=%0h", 
                     out_cta_id_x, out_cta_id_y, out_cta_id_z, out_cta_size, out_kernel_id);
            pass_count++;
        end else begin
            $display("✗ OUTPUT MISMATCH: Expected ID=(%0d,%0d,%0d) Size=%0d Kernel=%0h, Got ID=(%0d,%0d,%0d) Size=%0d Kernel=%0h",
                     expected.cta_id_x, expected.cta_id_y, expected.cta_id_z, expected.cta_size, expected.kernel_id,
                     out_cta_id_x, out_cta_id_y, out_cta_id_z, out_cta_size, out_kernel_id);
            fail_count++;
        end
        test_count++;
    endtask
    
    // Combined task to pop and verify output
    task pop_and_check(input logic [CTA_INDEX_WIDTH-1:0] cta_id, input cta_data_t expected);
        automatic logic match;
        
        @(negedge clk);
        pop_valid = 1;
        pop_hw_cta_id = cta_id;
        
        wait (out_valid);
        
        match = (out_cta_id_x == expected.cta_id_x) &&
                (out_cta_id_y == expected.cta_id_y) &&
                (out_cta_id_z == expected.cta_id_z) &&
                (out_cta_size == expected.cta_size) &&
                (out_kernel_id == expected.kernel_id);
        
        if (match) begin
            $display("✓ OUTPUT MATCH: ID=(%0d,%0d,%0d) Size=%0d Kernel=%0h", 
                     out_cta_id_x, out_cta_id_y, out_cta_id_z, out_cta_size, out_kernel_id);
            pass_count++;
        end else begin
            $display("✗ OUTPUT MISMATCH: Expected ID=(%0d,%0d,%0d) Size=%0d Kernel=%0h, Got ID=(%0d,%0d,%0d) Size=%0d Kernel=%0h",
                     expected.cta_id_x, expected.cta_id_y, expected.cta_id_z, expected.cta_size, expected.kernel_id,
                     out_cta_id_x, out_cta_id_y, out_cta_id_z, out_cta_size, out_kernel_id);
            fail_count++;
        end
        test_count++;
        
        @(negedge clk);
        pop_valid = 0;
        $display("Popped CTA %0d", cta_id);
    endtask
    
    // Task to consume output
    task consume_output();
        wait (out_valid);
        @(negedge clk);
        out_ready = 1;
        @(negedge clk);
        while (out_valid) @(negedge clk);
    endtask
    
    // Test cases
    initial begin
        $display("=== Active CTA Table Testbench Started ===");
        
        `ifdef XCELIUM
            $recordfile("active_cta_table.trn");
            $recordvars("");
        `endif
        $dumpfile("active_cta_table.vcd");
        $dumpvars(0, tb_active_cta_table);
        
        
        test_count = 0;
        pass_count = 0;
        fail_count = 0;
        
        init_signals();
        rst_n = 0;
        repeat(3) @(negedge clk);
        rst_n = 1;
        repeat(2) @(negedge clk);
        
        // Test 1: Basic reset state
        $display("\n--- Test 1: Reset State ---");
        if (!full && next_empty_cta_index == 0 && !out_valid && cta_valid == 0) begin
            $display("✓ Reset state correct");
            pass_count++;
        end else begin
            $display("✗ Reset state incorrect - cta_valid=%b", cta_valid);
            fail_count++;
        end
        test_count++;
        
        // Test 2: Add single CTA
        $display("\n--- Test 2: Add Single CTA ---");
        add_cta(0);
        @(negedge clk);
        if (!full && next_empty_cta_index == 1 && cta_valid == 4'b0001) begin
            $display("✓ Single CTA add successful - cta_valid=%b", cta_valid);
            pass_count++;
        end else begin
            $display("✗ Single CTA add failed - cta_valid=%b", cta_valid);
            fail_count++;
        end
        test_count++;
        
        // Test 3: Pop single CTA and check output
        $display("\n--- Test 3: Pop Single CTA ---");
        pop_and_check(0, test_ctas[0]);
        
        // Test 4: Fill table with single entry CTAs
        $display("\n--- Test 4: Fill Table Completely with Single Entries ---");
        for (int i = 0; i < MAX_NUM_CTA; i++) begin
            add_cta(i);
        end
        @(negedge clk);
        if (full && cta_valid == {MAX_NUM_CTA{1'b1}}) begin
            $display("✓ Table full correctly - cta_valid=%b", cta_valid);
            pass_count++;
        end else begin
            $display("✗ Table should be full - cta_valid=%b", cta_valid);
            fail_count++;
        end
        test_count++;
        
        // Test 5: Try to add when full
        $display("\n--- Test 5: Add When Full ---");
        @(negedge clk);
        add_valid = 1;
        @(negedge clk);
        if (!add_ready) begin
            $display("✓ Correctly rejected add when full");
            pass_count++;
        end else begin
            $display("✗ Should reject add when full");
            fail_count++;
        end
        add_valid = 0;
        test_count++;
        
        // Test 6: Pop all entries and verify order
        $display("\n--- Test 6: Pop All Entries ---");
        for (int i = 0; i < MAX_NUM_CTA; i++) begin
            pop_and_check(i, test_ctas[i]);
        end
        
        // Test 7: Verify empty state
        $display("\n--- Test 7: Empty State ---");
        @(negedge clk);
        if (!full && next_empty_cta_index == 0 && !out_valid && cta_valid == 0) begin
            $display("✓ Empty state correct - cta_valid=%b", cta_valid);
            pass_count++;
        end else begin
            $display("✗ Empty state incorrect - cta_valid=%b", cta_valid);
            fail_count++;
        end
        test_count++;
        
        // Test 8: Add multi-entry CTA
        $display("\n--- Test 8: Add Multi-Entry CTA ---");
        add_cta(4); // 2 entries
        @(negedge clk);
        if (!full && next_empty_cta_index == 2 && cta_valid == 4'b0001) begin // Wait, since slots 0 primary, 1 secondary, valid shows only primary
            // In the module, cta_valid[i] = cta_table[i].valid && cta_table[i].is_primary, so for multi, only the first is valid=1, others 0
            // So for one multi at 0-1, cta_valid = 4'b0001
            $display("✓ Multi-entry CTA add successful - cta_valid=%b next_empty=%d", cta_valid, next_empty_cta_index);
            pass_count++;
        end else begin
            $display("✗ Multi-entry CTA add failed - cta_valid=%b next_empty=%d", cta_valid, next_empty_cta_index);
            fail_count++;
        end
        test_count++;
        
        // Add another single
        add_cta(0); // single at 2
        @(negedge clk);
        if (!full && next_empty_cta_index == 3 && cta_valid == 4'b0101) begin // primaries at 0 and 3? No, slot 0 and 2
        // cta_valid[0]=1, [2]=1, so 4'b0101 ? Wait, LSB is slot0, so 4'b0101 is slot0 and slot2
            $display("✓ Added single after multi - cta_valid=%b", cta_valid);
            pass_count++;
        end else begin
            $display("✗ Add after multi failed - cta_valid=%b", cta_valid);
            fail_count++;
        end
        test_count++;
        
        // Pop the multi
        pop_and_check(0, test_ctas[4]);
        @(negedge clk);
        if (next_empty_cta_index == 0 && cta_valid == 4'b0100) begin // slot2 is 1, 4'b0100 is slot3? No
        // cta_valid is [3:0], bit0=slot0, bit1=slot1, bit2=slot2, bit3=slot3
        // After pop slot0 (multi 0-1), slots 0 and 1 free, next_empty=0, cta_valid[2]=1, so 4'b0100 ? Bit2 is 4'b0100
            $display("✓ After pop multi - cta_valid=%b next_empty=%d", cta_valid, next_empty_cta_index);
            pass_count++;
        end else begin
            $display("✗ After pop multi - cta_valid=%b", cta_valid);
            fail_count++;
        end
        test_count++;
        
        // Pop the single
        pop_and_check(2, test_ctas[0]);
        
        // Test 9: Rapid add/pop sequence
        $display("\n--- Test 9: Rapid Add/Pop Sequence ---");
        fork
            begin
                add_cta(0);
                add_cta(1);
            end
            begin
                #(CLK_PERIOD * 2);
                pop_and_check(0, test_ctas[0]);
                pop_and_check(0, test_ctas[1]);
            end
        join
        
        // Test 10: Output buffer backpressure
        $display("\n--- Test 10: Output Buffer Backpressure ---");
        add_cta(0);
        @(negedge clk);
        out_ready = 0;
        pop_cta(0);
        @(negedge clk);
        
        add_cta(1);
        pop_cta(0); // This pop should be ignored because buffer is full
        @(negedge clk);
        
        if (out_valid && out_cta_id_x == test_ctas[0].cta_id_x && out_cta_size == test_ctas[0].cta_size) begin
            $display("✓ Output buffer holding first CTA");
            pass_count++;
        end else begin
            $display("✗ Output buffer issue");
            fail_count++;
        end
        test_count++;
        
        // Release backpressure
        @(negedge clk);
        out_ready = 1;
        consume_output();
        
        // Check the second CTA is still in table, pop it
        pop_and_check(0, test_ctas[1]);
        
        // Summary
        $display("\n=== Test Summary ===");
        $display("Total Tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        
        if (fail_count == 0) begin
            $display("🎉 ALL TESTS PASSED!");
        end else begin
            $display("❌ %0d TESTS FAILED", fail_count);
        end
        
        $finish;
    end
    
    // Timeout watchdog
    initial begin
        #(CLK_PERIOD * 1000);
        $display("⚠️ TIMEOUT");
        $finish;
    end
    
    // Monitor
    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time=%0t: full=%b, next_empty=%0d, out_valid=%b, add_ready=%b, cta_valid=%b", 
                     $time, full, next_empty_cta_index, out_valid, add_ready, cta_valid);
        end
    end

endmodule