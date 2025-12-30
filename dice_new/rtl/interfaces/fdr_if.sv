
interface fdr_if ();

    logic valid;
    dice_frontend_pkg::fdr_t data;
    logic ready;

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
