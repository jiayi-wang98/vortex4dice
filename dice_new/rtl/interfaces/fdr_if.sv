
interface cta_sched_if import frontend_pkg::*; ();

    logic  valid;
    fdr_t data;
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