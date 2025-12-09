`include "VX_define.vh"

interface cta_sched_if import VX_gpu_pkg::*; ();

    logic  valid;
    schedule_t data;
    logic  ready;

    modport master (
        output valid,
        output data,
        input  ready
    );

    modport slave (
        input  valid,
        input  data,
        output ready
    );

endinterface






