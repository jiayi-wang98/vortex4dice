`include "VX_define.vh"

module bitstream_memory #(
    parameter DATA_SIZE = VX_gpu_pkg::VX_MEM_DATA_WIDTH / 8,
    parameter TAG_WIDTH = 48,
    parameter LATENCY   = 10
) (
    input logic clk,
    input logic reset,

    // Data to return for read requests
    input logic [DATA_SIZE*8-1:0] response_data,

    // Memory interface
    VX_mem_bus_if.slave mem_bus_if
);
    import VX_gpu_pkg::*;

    // Request Queue Entry
    typedef struct packed {
        logic [TAG_WIDTH-1:0]   uuid;
        // We capture input data at request time
        logic [DATA_SIZE*8-1:0] data;
        logic [63:0]            ready_cycle;
        logic                   rw;
    } req_entry_t;

    req_entry_t request_queue [$];
    logic [63:0] current_cycle;

    // Always accept requests
    assign mem_bus_if.req_ready = 1'b1;

    // Cycle Counter
    always_ff @(posedge clk) begin
        if (reset) begin
            current_cycle <= '0;
        end else begin
            current_cycle <= current_cycle + 1;
        end
    end

    // Request Handling
    always_ff @(posedge clk) begin
        if (reset) begin
            request_queue.delete();
        end else begin
            // Accept new requests
            if (mem_bus_if.req_valid && mem_bus_if.req_ready) begin
                // Check if it's a read request (rw=0 typically for read)
                if (!mem_bus_if.req_data.rw) begin
                    req_entry_t new_entry;
                    new_entry.uuid = mem_bus_if.req_data.tag.uuid;
                    new_entry.data = response_data;
                    new_entry.ready_cycle = current_cycle + LATENCY;
                    new_entry.rw = mem_bus_if.req_data.rw;
                    request_queue.push_back(new_entry);
                end
            end

            // Pop processed requests
            if (mem_bus_if.rsp_valid && mem_bus_if.rsp_ready) begin
                 void'(request_queue.pop_front());
            end
        end
    end

    // Response Logic
    always_comb begin
        mem_bus_if.rsp_valid = 1'b0;
        mem_bus_if.rsp_data  = '0;

        if (request_queue.size() > 0) begin
            // Check latency
            if (current_cycle >= request_queue[0].ready_cycle) begin
                mem_bus_if.rsp_valid = 1'b1;
                mem_bus_if.rsp_data.tag.uuid = request_queue[0].uuid;
                mem_bus_if.rsp_data.data     = request_queue[0].data;
            end
        end
    end

endmodule
