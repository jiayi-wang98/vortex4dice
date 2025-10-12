module dice_rf_address_converter #(
    parameter int NUM_BANK = 16,
    parameter int DEPTH = 512,
    parameter int ADDR_WIDTH = $clog2(DEPTH)
)(
    input  logic [ADDR_WIDTH-1:0] disp_tid,
    output logic [NUM_BANK*ADDR_WIDTH-1:0] rf_addr,

    //config
    input logic [NUM_BANK*ADDR_WIDTH-1:0] override_enable,
    input logic [NUM_BANK*ADDR_WIDTH-1:0] override_address,
);

    genvar i;
    generate
        for (i = 0; i < NUM_BANK; i++) begin : gen_addr
            for(int j = 0; j < ADDR_WIDTH; j++) begin
                assign rf_addr[i*ADDR_WIDTH + j] = (override_enable[i*ADDR_WIDTH + j]) ? override_address[i*ADDR_WIDTH + j] : disp_tid[j];
            end
        end
    endgenerate
endmodule