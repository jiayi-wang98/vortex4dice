module active_cta_table #(
    parameter int THREAD_WIDTH = 256  // Base thread width per CTA table entry
) (
    input logic clk_i,
    input logic rst_i,

    // Add new entry interface (table is slave)
    output logic                                             add_ready_o,
    input  logic                                             add_valid_i,
    input  dice_pkg::dice_cta_desc_t                         add_cta_info_i,
    input  logic           [dice_pkg::DICE_TID_WIDTH-1:0]    add_cta_size_i,

    // Pop interface
    input  logic                                             pop_valid_i,
    input  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0]        pop_hw_cta_id_i,
    output logic                                             pop_ready_o,

    // Output popped CTA interface (table is master)
    output logic                                             out_valid_o,
    input  logic                                             out_ready_i,
    output dice_pkg::dice_cta_id_t                           out_cta_id_o,
    output logic         [dice_pkg::DICE_TID_WIDTH-1:0]      out_cta_size_o,
    output logic         [dice_pkg::DICE_KERNEL_ID_WIDTH-1:0] out_kernel_id_o,

    // Status outputs
    output dice_frontend_pkg::active_cta_t [dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0] active_cta_entries_o,

    // Output flags
    output logic                                             full_o,
    output logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0]        next_empty_cta_index_o
);

  // Calculate number of entries needed for a CTA
  // Optimized for power-of-2 THREAD_WIDTH using bit shifts
  function automatic logic [dice_pkg::DICE_HW_CTA_ID_WIDTH:0] calc_entries_needed(
      input logic [dice_pkg::DICE_TID_WIDTH-1:0] cta_size);
    // For power-of-2 THREAD_WIDTH, we can use bit shifts
    // entries_needed = ceil(cta_size / THREAD_WIDTH) = (cta_size + THREAD_WIDTH - 1) >> log2(THREAD_WIDTH)
    logic [dice_pkg::DICE_TID_WIDTH-1:0] adjusted_size;
    adjusted_size = cta_size + THREAD_WIDTH - 1;
    return adjusted_size >> (dice_pkg::DICE_TID_WIDTH'($clog2(THREAD_WIDTH)));
  endfunction


  // CTA table entry structure
  typedef struct packed {
    logic is_primary;  // True for the first entry of a multi-entry CTA
    logic [$clog2(dice_pkg::DICE_NUM_MAX_CTA_PER_CORE):0] entries_used;  // Number of entries used by this CTA
    dice_frontend_pkg::active_cta_t entry_info;
  } cta_entry_t;


  // CTA table storage
  cta_entry_t cta_table_q[dice_pkg::DICE_NUM_MAX_CTA_PER_CORE-1:0];

  // Output buffer for popped entries (flip-flops)
  logic                                        output_buffer_valid_q;
  dice_pkg::dice_cta_id_t                      output_buffer_cta_id_q;
  logic [dice_pkg::DICE_TID_WIDTH-1:0]         output_buffer_cta_size_q;
  logic [dice_pkg::DICE_KERNEL_ID_WIDTH-1:0]   output_buffer_kernel_id_q;

  // Internal combinational signals
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH-1:0] empty_index;
  logic found_empty;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH:0] entries_needed;
  logic [dice_pkg::DICE_HW_CTA_ID_WIDTH:0] entries_to_clear;

  // Calculate entries needed for incoming CTA
  assign entries_needed = calc_entries_needed(add_cta_size_i);

  // Find next empty entry - Contiguous Block Search
  always_comb begin
    found_empty = 1'b0;
    empty_index = '0;

    // Search for a contiguous block of 'entries_needed' slots
    for (int i = 0; i <= dice_pkg::DICE_NUM_MAX_CTA_PER_CORE - 1; i++) begin
      logic block_valid;
      block_valid = 1'b1;

      // Check if the block fits within the table bounds
      if ((i + entries_needed) <= dice_pkg::DICE_NUM_MAX_CTA_PER_CORE) begin
        // Check if all slots in the block are empty
        for (int k = 0; k < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; k++) begin
           if (k >= i && k < (i + entries_needed)) begin
              if (cta_table_q[k].entry_info.cta_valid == 1'b1) begin
                  block_valid = 1'b0;
              end
           end
        end

        if ((block_valid == 1'b1) && (found_empty == 1'b0)) begin
          empty_index = (dice_pkg::DICE_HW_CTA_ID_WIDTH)'(i);
          found_empty = 1'b1;
        end
      end
    end
  end

  // Output assignments
  assign full_o = (found_empty == 1'b0);
  assign next_empty_cta_index_o = empty_index;
  assign add_ready_o = found_empty;

  // Output interface
  assign out_valid_o = output_buffer_valid_q;
  assign out_cta_id_o = output_buffer_cta_id_q;
  assign out_cta_size_o = output_buffer_cta_size_q;
  assign out_kernel_id_o = output_buffer_kernel_id_q;

  logic pop_this_cycle;
  logic output_consumed_this_cycle;

  // Pop ready when buffer is empty or being consumed this cycle
  assign pop_ready_o = (output_buffer_valid_q == 1'b0) || (output_consumed_this_cycle == 1'b1);

  assign pop_this_cycle = (pop_valid_i == 1'b1) && (pop_ready_o == 1'b1) &&
                          (cta_table_q[pop_hw_cta_id_i].entry_info.cta_valid == 1'b1);
  assign output_consumed_this_cycle = (out_valid_o == 1'b1) && (out_ready_i == 1'b1);

  // CTA valid outputs and status information - only from primary entries
  always_comb begin
    for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
      if ((cta_table_q[i].entry_info.cta_valid == 1'b1) && (cta_table_q[i].is_primary == 1'b1)) begin
        active_cta_entries_o[i] = cta_table_q[i].entry_info;
      end else begin
        active_cta_entries_o[i] = '0;
      end
    end
  end


  // Main table logic
  always_ff @(posedge clk_i) begin
    if (rst_i == 1'b1) begin
      // Reset all entries
      for (int i = 0; i < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; i++) begin
        cta_table_q[i] <= '0;
      end
      // Reset output buffer
      output_buffer_valid_q <= 1'b0;
      output_buffer_cta_id_q <= '0;
      output_buffer_cta_size_q <= '0;
      output_buffer_kernel_id_q <= '0;

    end else begin
      // Compute entries_to_clear for pop operations
      entries_to_clear = cta_table_q[pop_hw_cta_id_i].entries_used;

      if ((pop_this_cycle == 1'b1) && (output_consumed_this_cycle == 1'b1)) begin
        // Pop and output in same cycle - directly replace buffer contents
        output_buffer_valid_q <= 1'b1;
        output_buffer_cta_id_q <= cta_table_q[pop_hw_cta_id_i].entry_info.cta_id;
        output_buffer_cta_size_q <= (dice_pkg::DICE_TID_WIDTH)'(cta_table_q[pop_hw_cta_id_i].entry_info.hw_cta_size);
        output_buffer_kernel_id_q <= cta_table_q[pop_hw_cta_id_i].entry_info.kernel_id;

        // Clear all entries used by this CTA
        for (int j = 0; j < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; j++) begin
          if (j >= pop_hw_cta_id_i && j < (pop_hw_cta_id_i + entries_to_clear)) begin
            cta_table_q[j] <= '0;
          end
        end

      end else if ((pop_this_cycle == 1'b1) && (output_buffer_valid_q == 1'b0)) begin
        // Pop when buffer is empty - store in buffer
        output_buffer_valid_q <= 1'b1;
        output_buffer_cta_id_q <= cta_table_q[pop_hw_cta_id_i].entry_info.cta_id;
        output_buffer_cta_size_q <= (dice_pkg::DICE_TID_WIDTH)'(cta_table_q[pop_hw_cta_id_i].entry_info.hw_cta_size);
        output_buffer_kernel_id_q <= cta_table_q[pop_hw_cta_id_i].entry_info.kernel_id;

        // Clear all entries used by this CTA
        for (int j = 0; j < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; j++) begin
          if (j >= pop_hw_cta_id_i && j < (pop_hw_cta_id_i + entries_to_clear)) begin
            cta_table_q[j] <= '0;
          end
        end

      end else if (output_consumed_this_cycle == 1'b1) begin
        // Only output buffer consumed - clear buffer
        output_buffer_valid_q <= 1'b0;
        output_buffer_cta_id_q <= '0;
        output_buffer_cta_size_q <= '0;
        output_buffer_kernel_id_q <= '0;
      end
      // If pop_this_cycle && output_buffer_valid && !output_consumed_this_cycle
      // then we can't pop because buffer is full - pop is ignored

      // Handle add operation
      if ((add_valid_i == 1'b1) && (add_ready_o == 1'b1)) begin
        // Allocate consecutive entries for this CTA
        for (int j = 0; j < dice_pkg::DICE_NUM_MAX_CTA_PER_CORE; j++) begin
          if (j >= empty_index && j < (empty_index + entries_needed)) begin
            if (j == empty_index) begin
              cta_table_q[j].entry_info.cta_id <= add_cta_info_i.cta_id;
              cta_table_q[j].entry_info.grid_size <= add_cta_info_i.kernel_desc.grid_size;
              cta_table_q[j].entry_info.cta_size <= add_cta_info_i.kernel_desc.cta_size;
              cta_table_q[j].entry_info.kernel_id <= add_cta_info_i.kernel_desc.kernel_id;
              cta_table_q[j].entry_info.smem_per_cta <= add_cta_info_i.kernel_desc.smem_per_cta;
              cta_table_q[j].entry_info.hw_cta_size <= (dice_pkg::DICE_HW_CTA_SIZE_WIDTH)'(add_cta_size_i);
            end else begin
              cta_table_q[j] <= '0;
            end
            cta_table_q[j].entry_info.cta_valid <= 1'b1;
            cta_table_q[j].is_primary <= (j == empty_index);
            cta_table_q[j].entries_used <= entries_needed;
          end
        end
      end
    end
  end



  `ifndef SYNTHESIS
  always_ff @(posedge clk_i) begin
    if (rst_i == 1'b0) begin
      if ((add_valid_i == 1'b1) && (add_ready_o == 1'b1)) begin
        assert ((empty_index + entries_needed) <= dice_pkg::DICE_NUM_MAX_CTA_PER_CORE)
        else $error("ContiguousAllocation: Allocated block exceeds table bounds");
      end

      if (pop_valid_i == 1'b1) begin
        assert (cta_table_q[pop_hw_cta_id_i].entry_info.cta_valid == 1'b1)
        else $error("PopValidEntry: Popping invalid entry");
      end

      if (out_valid_o == 1'b1) begin
        assert (!$isunknown(out_cta_id_o))
        else $error("OutputKnown: Output ID contains X");
      end
    end
  end
  `endif

endmodule
