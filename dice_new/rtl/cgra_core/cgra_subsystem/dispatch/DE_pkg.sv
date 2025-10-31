`ifndef DEIMPORTS
`define DEIMPORTS

package DE_pkg;
typedef struct packed {
    logic[5:0]  tid;
    logic[31:0] data;
    logic       we;
    
} reg_wr_cmd;

typedef struct packed {
    logic[5:0] tid;
    logic      re;
} reg_rd_cmd;

endpackage
`endif