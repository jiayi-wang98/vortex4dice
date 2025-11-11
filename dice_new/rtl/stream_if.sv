interface stream_if #(
    parameter int BITSTREAM_DATA_WIDTH = 64
)(
    input logic clk,
    input logic rst_n
);

    logic valid;
    logic ready;
    logic addr;
    logic [BITSTREAM_DATA_WIDTH-1:0] data;

    modport initiator (
        input ready,
        input addr,
        output valid,
        output data
    );

    modport target (
        output ready,
        output addr,
        input valid,
        input data
    );

endinterface