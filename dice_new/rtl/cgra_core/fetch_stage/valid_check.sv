/*
CONDITIONS FOR VALID TO BE ASSERTED:
1) Bitstream Loaded
2) E-block prefetch cleared or not prefetch block
3) Valid mask 
4) Barrier condition met - NEED TO FIGURE OUT WHO UPDATES THIS IN THE STATUS TABLE (says decoder does / decoder keeps track of it
and gets the info from the retire table. I assume it will be easier to have the decoder just read from the status table
and have a separate controller for the status table -> will make decoder assuming that)
*/
 //TO DO: Ensure that the prefetch and unresolved divergence is correct
module valid_check #(
    parameter PC_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,

    //from decoder (if it is 1 then all prev blocks must finish before ex this p graph)
    input logic barrier_indicator,
    input logic mask_valid,
    output logic valid_ready,

    //from CS, FDR buffer
    input logic [PC_WIDTH-1:0] eblock_pc,
    input logic prefetch_block,

    //from SIMT_Stack
    input logic [PC_WIDTH-1:0] simt_stack_pc, // "next pc"

    
    input logic bitstream_valid,
    output logic bitstream_ready,

    //from cta status table
    input logic unresolved_div,
    input logic barrier_done,


    //to FDR DE buffer
    output logic fdr_valid,
    input logic ex_ready
);

    //'STATES'
    logic valid_d, valid_q; 

    //intermediate signals
    logic pc_match; //if the pc from the simt stack and the pc from schedule match
    logic prefetch_ok; // if it is either not a prefetch block, or the prefetch condition has been cleared
    logic bitstream_ok; //if bitstream is loaded
    logic mask_ok; //if mask is valid
    logic barrier_ok; //if barrier condition is met
    logic no_divergence; //MAY NEED TO MODIFY


    logic can_issue; // true if all conditions are valid
    logic is_issued; // asserted when the FDR stage is valid and the EX stage is ready

    assign pc_match = eblock_pc == simt_stack_pc;
    assign prefetch_ok = !prefetch_block; //NEED TO MODIFY
    assign bitstream_ok = bitstream_valid;
    assign mask_ok = mask_valid;
    assign barrier_ok = barrier_done || (!barrier_indicator);
    assign no_divergence = !unresolved_div;

    //checks if all conditions are true
    assign can_issue = pc_match         && 
                       prefetch_ok      &&
                       bitstream_ok     &&
                       barrier_ok       &&
                       mask_ok          &&
                       no_divergence;

    assign valid_ready = (!valid_q) || (valid_q && ex_ready); //may not need this -> need to assess decode logic
    assign is_issued = can_issue && ex_ready;
    assign fdr_valid = valid_q;


    always_comb begin
        valid_d = valid_q;
        if (valid_q) begin
            if (ex_ready) begin
                if (can_issue) begin
                    valid_d = 1'b1;
                end else begin
                    valid_d = 1'b0;
                end
            end else begin
                valid_d = 1'b1;
            end
        end else begin
            if (can_issue) begin
                valid_d = 1'b1;
            end
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_q <= 1'b0;
        end else begin
            valid_q <= valid_d;
        end
    end
endmodule