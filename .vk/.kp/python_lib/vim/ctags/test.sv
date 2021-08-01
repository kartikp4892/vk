//$INSERT_HEADER_HERE

parameter abc = "hi";

`ifndef UART_TYPEDEF_PKG_SV
`define UART_TYPEDEF_PKG_SV

//--------------------------------------------------------------------
// package name : uart_typedef_pkg
// Description  : This package has all the typdef's required for
//                uart UVC.
//--------------------------------------------------------------------
`include "uart_macros.svh"
package uart_typedef_pkg;

// Typedef        : trans_type_t 
// Description    : Enum type for transaction type
typedef enum bit {
  UART_COMMAND,
  UART_RESPONSE
} trans_type_t;


endpackage : uart_typedef_pkg

`endif // UART_TYPEDEF_PKG_SV 




