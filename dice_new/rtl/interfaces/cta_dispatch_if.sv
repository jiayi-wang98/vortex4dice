`ifndef CTA_DISPATCH_IF_SV
`define CTA_DISPATCH_IF_SV

interface cta_dispatch_if
  import dice_pkg::*;
();

  logic           valid;
  dice_cta_desc_t data;
  logic           ready;

  modport master(output valid, output data, input ready);

  modport slave(input valid, input data, output ready);

endinterface

`endif  // CTA_DISPATCH_IF_SV
