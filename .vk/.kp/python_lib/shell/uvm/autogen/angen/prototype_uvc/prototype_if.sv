//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_IF_SV
`define PROTOTYPE_IF_SV

//--------------------------------------------------------------------
// Interface name  : prototype_if
// Description     : This is the prototype nterface which has some of the 
//                   signals like reset, clock and other signals.
//------------------------------------------------------------------
interface prototype_if();

  `include "prototype_parameters.sv"

  // Active low reset signal
  logic reset_f;

  // TODO : Add all the required signals and add them to driver and monitor mode port as needed.

  // Modport for driver
  modport driver_mp(input reset_f);

  // Modport for monitor 
  modport monitor_mp(input reset_f);

endinterface : prototype_if

`endif // PROTOTYPE_IF_SV
