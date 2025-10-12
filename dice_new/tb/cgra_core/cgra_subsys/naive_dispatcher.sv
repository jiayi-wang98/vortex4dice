module naive_dispatcher #(
    parameter TOTAL_TID = 512
)(
    input logic clk,
    input logic rst_n,
    input logic enable,
    input logic clr,
    input logic [$clog2(TOTAL_TID+1)-1:0] max_tid,
    output logic done,
    output logic [$clog2(TOTAL_TID+1)-1:0] dispatch_tid,
    output logic tid_valid
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done <= 0;
            dispatch_tid <= 0;
            tid_valid <= 0;
        end else if (enable) begin
            if (done) begin
                tid_valid <= 0;
            end else if (dispatch_tid == max_tid) begin
                done <= 1;
                tid_valid <= 1;
            end else begin
                done <= 0;
                dispatch_tid <= dispatch_tid + 1;
                tid_valid <= 1;
            end
        end else if (clr) begin
            done <= 0;
            dispatch_tid <= 0;
            tid_valid <= 0;
        end
    end
endmodule