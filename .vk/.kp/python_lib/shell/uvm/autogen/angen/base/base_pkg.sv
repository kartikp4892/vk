//$INSERT_HEADER_HERE

`ifndef BASE_PKG_SV
`define BASE_PKG_SV

//--------------------------------------------------------------------
// Class name  : base_pkg
// Description : This is the base components pacckage which has
//               all the components from which all the UVC components
//               will be extended.
//------------------------------------------------------------------
package base_pkg;
// Import the external packages
import uvm_pkg::*;

// Include all the base files to the base package
include "base_methods.sv";
include "base_macros.svh";
include "base_config.sv";
include "base_driver.sv";
include "base_monitor.sv";
include "base_sequencer.sv";
include "base_agent.sv";
include "base_test.sv";
include "base_transaction.sv";
include "base_sequence.sv";
include "base_env.sv";

// `include "uart_macros.svh"
// `include "uart_if_base_api.sv";
endpackage : base_pkg	 

`endif // BASE_PKG_SV
