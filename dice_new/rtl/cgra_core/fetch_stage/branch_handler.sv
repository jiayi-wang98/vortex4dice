import frontend_pkg::*;


module branch_handler #(
    parameter MASK_WIDTH = 512
)(
    input logic clk,
    input logic rst_n,


    //dispatcher



    //pdom stack controller



    //CS and FDR Stage Regs




    //CTA Status Table


    //decoder
    input logic [31:0] branch_metadata,
    input logic branch_req_valid, //one cycle -> may remove

    output logic [MASK_WIDTH-1:0] real_active_thread_mask,
    output logic mask_valid
);







    always_comb begin


    end




endmodule