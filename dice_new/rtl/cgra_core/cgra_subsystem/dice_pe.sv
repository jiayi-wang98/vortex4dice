module dice_pe (
  input logic clk,
  input logic rst_n,
  input logic [31:0] pe_in0,
  input logic [31:0] pe_in1,
  input logic [31:0] pe_in2,
  input logic [0:0] pe_in3,
  input logic [31:0] dff_in,
  output logic [31:0] pe_out_t0,
  output logic [31:0] pe_out_t1,
  output logic [0:0] pe_out_p0,

  //static CFG
  input logic [31:0] opcode,
  input logic [0:0] out_sel,

  //dynamic CFG
  input logic dff_input_mode,
  input logic dff_output_mode
);

  logic [31:0] out0;
  logic [0:0] out1;

    dice_alu alu_inst (
        .clk(clk),
        .in0(pe_in0),
        .in1(pe_in1),
        .in2(pe_in2),
        .in3(pe_in3),
        .opcode(opcode),
        .out0(out0),
        .out1(out1)
    );


    logic [31:0] dff0;
    logic [31:0] dff1;
    logic dff_in_enable,dff_in_enable_pre;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dff_in_enable_pre <= 1'b0;
        end else begin
            dff_in_enable_pre <= dff_input_mode;
        end
    end


    //when this signal changes, enable input dff
    assign dff_in_enable = dff_input_mode ^ dff_in_enable_pre;
    

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dff0 <= 32'b0;
            dff1 <= 32'b0;
        end else begin
            if (dff_input_mode) begin
                if(dff_in_enable) begin
                    dff0 <= dff_in;
                end //else keep the value
                dff1 <= out0;
            end else begin
                if(dff_in_enable) begin
                    dff1 <= dff_in;
                end //else keep the value
                dff0 <= out0;
            end
        end
    end

    logic [31:0] dff_out;
    assign dff_out = dff_output_mode ? dff1 : dff0;

    assign pe_out_t0 = out_sel ? dff_out : out0;
    assign pe_out_t1 = dff_output_mode ? dff0 : dff1;
    assign pe_out_p0 = out1;

endmodule