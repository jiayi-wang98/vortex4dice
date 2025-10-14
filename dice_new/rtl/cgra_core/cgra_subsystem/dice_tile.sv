module dice_tile (
    input logic clk,
    input logic rst_n,
    //North port
    input logic [31:0] N_in_t0,
    input logic [31:0] N_in_t1,
    output logic [31:0] N_out_t0,
    output logic [31:0] N_out_t1,
    input logic  N_in_p0,
    input logic N_in_p1,
    output logic N_out_p0,
    output logic N_out_p1,

    //East port
    input logic [31:0] E_in_t0,
    input logic [31:0] E_in_t1,
    output logic [31:0] E_out_t0,
    output logic [31:0] E_out_t1,
    input logic  E_in_p0,
    input logic E_in_p1,
    output logic E_out_p0,
    output logic E_out_p1,

    //South port
    input logic [31:0] S_in_t0,
    input logic [31:0] S_in_t1,
    output logic [31:0] S_out_t0,
    output logic [31:0] S_out_t1,
    input logic  S_in_p0,
    input logic S_in_p1,
    output logic S_out_p0,
    output logic S_out_p1,

    //West port
    input logic [31:0] W_in_t0,
    input logic [31:0] W_in_t1,
    output logic [31:0] W_out_t0,
    output logic [31:0] W_out_t1,
    input logic  W_in_p0,
    input logic W_in_p1,
    output logic W_out_p0,
    output logic W_out_p1,


    //static CFG
    input logic [155:0] tile_cfg
);

    logic dff_input_mode;
    logic dff_output_mode;
    logic [31:0] pe_out_t0;
    logic [31:0] pe_out_t1;
    logic pe_out_p0;
    logic [31:0] L_out_t0;
    logic [31:0] L_out_t1;
    logic [31:0] L_out_t2;
    logic [31:0] L_out_t3;
    logic L_out_p0;
    logic L_out_p1;
    logic L_out_p2;
    //initialize the router
    //total cfg bits:
    //2_1 router: 11 + 11*4 = 55
        // 11 bits for registered_mode
        // 11*4 bits for sel
    //2_32 router: 8 + 12 + 4 * 12 = 68
        // 8 bits for overload_en
        // 12*4 bits for registered_mode
        // 4*12 bits for sel
    //PE: opcode 32 + out_sel 1 = 33
        // 32 bits for opcode
        // 1 bit for out_sel
    //total = 156
    dice_2_1_router u_pred_router (
        .clk(clk),
        .rst_n(rst_n),
        .registered_mode_N_t0(tile_cfg[0]),
        .registered_mode_N_t1(tile_cfg[1]),
        .registered_mode_E_t0(tile_cfg[2]),
        .registered_mode_E_t1(tile_cfg[3]),
        .registered_mode_S_t0(tile_cfg[4]),
        .registered_mode_S_t1(tile_cfg[5]),
        .registered_mode_W_t0(tile_cfg[6]),
        .registered_mode_W_t1(tile_cfg[7]),
        .registered_mode_L_t0(tile_cfg[8]),
        .registered_mode_L_t1(tile_cfg[9]),
        .registered_mode_L_t2(tile_cfg[10]),
        .N_in_t0(N_in_p0),
        .N_in_t1(N_in_p1),
        .E_in_t0(E_in_p0),
        .E_in_t1(E_in_p1),
        .S_in_t0(S_in_p0),
        .S_in_t1(S_in_p1),
        .W_in_t0(W_in_p0),
        .W_in_t1(W_in_p1),
        .L_in_t0(pe_out_p0),
        .N_out_t0(N_out_p0),
        .N_out_t1(N_out_p1),
        .E_out_t0(E_out_p0),
        .E_out_t1(E_out_p1),
        .S_out_t0(S_out_p0),
        .S_out_t1(S_out_p1),
        .W_out_t0(W_out_p0),
        .W_out_t1(W_out_p1),
        .L_out_t0(L_out_p0),
        .L_out_t1(L_out_p1),
        .L_out_t2(L_out_p2),
        .sel_N_t0(tile_cfg[14:11]),
        .sel_N_t1(tile_cfg[18:15]),
        .sel_E_t0(tile_cfg[22:19]),
        .sel_E_t1(tile_cfg[26:23]),
        .sel_S_t0(tile_cfg[30:27]),
        .sel_S_t1(tile_cfg[34:31]),
        .sel_W_t0(tile_cfg[38:35]),
        .sel_W_t1(tile_cfg[42:39]),
        .sel_L_t0(tile_cfg[46:43]),
        .sel_L_t1(tile_cfg[50:47]),
        .sel_L_t2(tile_cfg[54:51])
    );

    dice_2_32_router u_data_router (
        .clk(clk),
        .rst_n(rst_n),
        .overload_en_N_t0(tile_cfg[55]),
        .overload_ctrl_N_t0(N_out_p0),
        .overload_en_N_t1(tile_cfg[56]),
        .overload_ctrl_N_t1(N_out_p1),
        .overload_en_E_t0(tile_cfg[57]),
        .overload_ctrl_E_t0(E_out_p0),
        .overload_en_E_t1(tile_cfg[58]),
        .overload_ctrl_E_t1(E_out_p1),
        .overload_en_S_t0(tile_cfg[59]),
        .overload_ctrl_S_t0(S_out_p0),
        .overload_en_S_t1(tile_cfg[60]),
        .overload_ctrl_S_t1(S_out_p1),
        .overload_en_W_t0(tile_cfg[61]),
        .overload_ctrl_W_t0(W_out_p0),
        .overload_en_W_t1(tile_cfg[62]),
        .overload_ctrl_W_t1(W_out_p1),
        .overload_en_L_t0('0),
        .overload_ctrl_L_t0('0),
        .overload_en_L_t1('0),
        .overload_ctrl_L_t1('0),
        .overload_en_L_t2('0),
        .overload_ctrl_L_t2('0),
        .overload_en_L_t3('0),
        .overload_ctrl_L_t3('0),
        .registered_mode_N_t0(tile_cfg[63]),
        .registered_mode_N_t1(tile_cfg[64]),
        .registered_mode_E_t0(tile_cfg[65]),
        .registered_mode_E_t1(tile_cfg[66]),
        .registered_mode_S_t0(tile_cfg[67]),
        .registered_mode_S_t1(tile_cfg[68]),
        .registered_mode_W_t0(tile_cfg[69]),
        .registered_mode_W_t1(tile_cfg[70]),
        .registered_mode_L_t0(tile_cfg[71]),
        .registered_mode_L_t1(tile_cfg[72]),
        .registered_mode_L_t2(tile_cfg[73]),
        .registered_mode_L_t3(tile_cfg[74]),
        .N_in_t0(N_in_t0),
        .N_in_t1(N_in_t1),
        .E_in_t0(E_in_t0),
        .E_in_t1(E_in_t1),
        .S_in_t0(S_in_t0),
        .S_in_t1(S_in_t1),
        .W_in_t0(W_in_t0),
        .W_in_t1(W_in_t1),
        .L_in_t0(pe_out_t0),
        .L_in_t1(pe_out_t1),
        .N_out_t0(N_out_t0),
        .N_out_t1(N_out_t1),
        .E_out_t0(E_out_t0),
        .E_out_t1(E_out_t1),
        .S_out_t0(S_out_t0),
        .S_out_t1(S_out_t1),
        .W_out_t0(W_out_t0),
        .W_out_t1(W_out_t1),
        .L_out_t0(L_out_t0),
        .L_out_t1(L_out_t1),
        .L_out_t2(L_out_t2),
        .L_out_t3(L_out_t3),
        .sel_N_t0(tile_cfg[78:75]),
        .sel_N_t1(tile_cfg[82:79]),
        .sel_E_t0(tile_cfg[86:83]),
        .sel_E_t1(tile_cfg[90:87]),
        .sel_S_t0(tile_cfg[94:91]),
        .sel_S_t1(tile_cfg[98:95]),
        .sel_W_t0(tile_cfg[102:99]),
        .sel_W_t1(tile_cfg[106:103]),
        .sel_L_t0(tile_cfg[110:107]),
        .sel_L_t1(tile_cfg[114:111]),
        .sel_L_t2(tile_cfg[118:115]),
        .sel_L_t3(tile_cfg[122:119])
    );
    //initialize the PE
    dice_pe pe_inst (
        .clk(clk),
        .rst_n(rst_n),
        .pe_in0(L_out_t0),
        .pe_in1(L_out_t1),
        .pe_in2(L_out_t2),
        .pe_in3(L_out_p0),
        .dff_in(L_out_t3),
        .pe_out_t0(pe_out_t0),
        .pe_out_t1(pe_out_t1),
        .pe_out_p0(pe_out_p0),

        //static CFG
        .opcode(tile_cfg[154:123]),
        .out_sel(tile_cfg[155]),

        //dynamic CFG
        .dff_input_mode(L_out_p0),
        .dff_output_mode(L_out_p1)
    );


endmodule
