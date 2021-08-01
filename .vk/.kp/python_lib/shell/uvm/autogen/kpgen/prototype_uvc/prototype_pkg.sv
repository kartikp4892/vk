//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_PKG_SV
`define PROTOTYPE_PKG_SV
 
// Including other files.
`include "prototype_typedef_pkg.sv"
`include "prototype_if.sv"

//--------------------------------------------------------------------
// package name : prototype_pkg
// Description  : This is package has all the files included and imported
//                for the prototype UVC. 
//------------------------------------------------------------------
package prototype_pkg;

  // Import external packages 
  import uvm_pkg::*;
  import base_pkg::*;
  import prototype_typedef_pkg::*;

  // Include all supporting files for prototype UVC
  `include "base_macros.svh";
  `include "prototype_parameters.sv";
  `include "prototype_config.sv";
  `include "prototype_transaction.sv";
  `include "prototype_driver.sv";
  `include "prototype_sequencer.sv";
  `include "prototype_monitor.sv";
  `include "prototype_agent.sv";
  `include "prototype_sequences.sv";
  `include "prototype_hdl_methods.sv";

endpackage : prototype_pkg

`endif // PROTOTYPE_PKG_SV 
