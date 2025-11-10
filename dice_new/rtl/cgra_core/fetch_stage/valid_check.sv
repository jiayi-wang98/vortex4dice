/*
Need to learn more about barrier condition and what that means for the validity,
need to figure out how decoder and branch handler should tell module if they are done
*/


module valid_check #(
    parameter PC_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,

    //from decoder (if it is 1 then all prev blocks must finish before ex this p graph)
    input logic barrier_indicator,

    //from CS, FDR buffer
    input logic [PC_WIDTH-1:0] eblock_pc,


    //from SIMT_Stack
    input logic [PC_WIDTH-1:0] simt_stack_pc, // "next pc"


    //from bitstream loader,
    input logic bitstream_loaded,


    //from cta status table
    input logic unresolved_div,


    //to FDR DE buffer
    output logic fdr_valid
);

    logic valid_d, valid_q;
    logic pc_match;
    logic barrier_cond_met;



    assign fdr_valid = valid_q;

    assign pc_match = (eblock_pc == simt_stack_pc);

    //
    assign valid_d = (pc_match && bitstream_loaded && !unresolved_div && barrier_cond_met);

    //may need to add more logic for barrier condition
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_q <= 1'b0;
        end else begin
            valid_q <= valid_d;
        end
    end

endmodule