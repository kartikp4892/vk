//$INSERT_HEADER_HERE

//--------------------------------------------------------------------
// Description : This file inlude uvmmacros.svh and add some additional
//               macros.
//------------------------------------------------------------------
`ifndef BASE_MACROS_SVH
`define BASE_MACROS_SVH

// Include all the uvm macros 
include "uvm_macros.svh";

// Array to store different pass message ID's
static byte pass_msg_id[string];

// Array to disable the printing specific error message
static bit disable_check_id[string];

// Array to store minimum times passing message to be displayed
static byte min_pass_msg[string];

// Default verbosity level for displaying passing messages 
static uvm_verbosity pass_msg_verb = UVM_LOW;

//--------------------------------------------------------------------
// Macro name  : set_min_pass_msg
// Arguments   : ID - Indicate the ID of the checker.
//               VALUE - Numer of times user want to display passing msg.
//                       Set this to -1 will set this limit to infinite.
// Description : By default pass messages will be displayed once only.
//               This macro is used to increase limit of displaying
//               passing messages.
//--------------------------------------------------------------------
`define set_min_pass_msg(ID,VALUE) \
begin \
  min_pass_msg[ID] = VALUE; \
end

//--------------------------------------------------------------------
// Macro name  : disable_check_for_ID
// Arguments   : ID - Indicate the ID of the checker.
// Description : Disable the checker of the given ID. Default it's enabled.
//--------------------------------------------------------------------
`define disable_check_for_ID(ID) \
begin \
  disable_check_id[ID] = 1'b1; \
end

//--------------------------------------------------------------------
// Macro name  : enable_check_for_ID
// Arguments   : ID - Indicate the ID of the checker.
// Description : Eanble the checker of the given ID.
//--------------------------------------------------------------------
`define enable_check_for_ID(ID) \
begin \
  disable_check_id[ID] = 1'b0; \
end

//--------------------------------------------------------------------
// Macro name  : pass_msg 
// Arguments   : ID - Indicate the ID of the checker.
//               MSG - Message to be displayed. 
// Description : Macro to display passing messges. By default they will
//               be displayed one only.
//--------------------------------------------------------------------
`define pass_msg(ID, MSG) \
begin \
  automatic bit display_en = 0; \
  if (!pass_msg_id.exists(ID)) begin \
    pass_msg_id[ID] = 1; \
    display_en = 1; \
    if(!min_pass_msg.exists(ID)) begin \
      min_pass_msg[ID] = 1; \
    end \
  end \
  else if(pass_msg_id[ID] < min_pass_msg[ID] || min_pass_msg[ID] == -1) begin \
    pass_msg_id[ID]++; \
    display_en = 1; \
  end \
  if(display_en == 1) begin \
    if (uvm_report_enabled(pass_msg_verb,UVM_INFO,ID)) \
      uvm_report_info (ID, $psprintf("PASS : %0s",MSG), pass_msg_verb, `uvm_file, `uvm_line, "", 1); \
  end \
end

//--------------------------------------------------------------------
// Macro name  : fail_msg 
// Arguments   : ID - Indicate the ID of the checker.
//               MSG - Message to be displayed. 
// Description : Macro to display fail messges if not disabled.
//--------------------------------------------------------------------
`define fail_msg(ID, MSG) \
begin \
  if (uvm_report_enabled(UVM_NONE,UVM_ERROR,ID)) \
    if(disable_check_id.exists(ID)) \
  if(disable_check_id[ID] == 1'b0) \
    uvm_report_error (ID, $psprintf("FAIL : %0s",MSG), UVM_NONE, `uvm_file, `uvm_line, "", 1); \
  else \
    uvm_report_error (ID, $psprintf("FAIL : %0s",MSG), UVM_NONE, `uvm_file, `uvm_line, "", 1); \
end

`ifndef ASSERT_MSG_INFO_CNTRL
`define ASSERT_MSG_INFO_CNTRL
//------------------------------------------------------------------------------
// Method name         : msg_info                            
// Parameters passed   : ID - Indicate the ID of the Assertion                        
//                       msg - Message to be displayed.                        
// Description         : Method to print pass messages. 
//
// This will control pass messages of the assertion such that it will display
// first pass message only. This will avoid unnecessary flooding of pass
// messages for the same assertion in simulation log file.
//------------------------------------------------------------------------------
function void msg_info(string ID,msg);
  `pass_msg(ID,msg);
endfunction : msg_info
`endif // ASSERT_MSG_INFO_CNTRL

`ifndef ASSERT_ERROR_MSG_INFO_CNTRL
`define ASSERT_ERROR_MSG_INFO_CNTRL
//------------------------------------------------------------------
// Method name         : msg_error_info                            
// Parameters passed   : ID - Indicate the ID of the Assertion                        
//                       msg - Message to be displayed.                        
// Description         : Method to print error messages                                       
//------------------------------------------------------------------
function void msg_error_info(string ID,msg);
  `fail_msg(ID, msg);
endfunction : msg_error_info
`endif // ASSERT_ERROR_MSG_INFO_CNTRL

//---------------------------------------------------------
// Macros to Print Relevant Assertion Messages
//---------------------------------------------------------
`ifndef ASSERT_MSG_INFO
`define ASSERT_MSG_INFO(ID,str1) msg_info(string'(ID),string'(str1))
`endif

`ifndef ASSERT_ERROR_MSG_INFO
`define ASSERT_ERROR_MSG_INFO(ID,str1) msg_error_info(string'(ID),string'(str1))
`endif

`endif // BASE_MACROS_SVH
