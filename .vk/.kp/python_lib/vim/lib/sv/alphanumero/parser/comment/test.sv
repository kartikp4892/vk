`ifndef TEST_SV
`define TEST_SV

//-------------------------------------------------------------------------------
// Class          : test 
// Parent         : uvm_component 
// Parameters     : type REQ 
//                  type RSP 
// Description    : this is read description
//-------------------------------------------------------------------------------
class test #(type REQ=trans, RSP= REQ) extends uvm_component;
  
  // Variable       : bit_counter 
  // Description    : 
  bit [7:0] bit_counter;

  // Port           : trans_export 
  // Description    : 
  uvm_analysis_imp#(trans, test) trans_export;

  // Typedef        : ucomp 
  // Description    : 
  typedef uvm_component ucomp;

  `uvm_component_utils (test)

  //-------------------------------------------------------------------------------
  // Function       : new 
  // Arguments      : string name 
  //                  uvm_component parent 
  // Description    : Constructor for creating this class object
  //-------------------------------------------------------------------------------
  function new(string name, uvm_component parent = null);
    super.new(name,parent);

  endfunction

  //-------------------------------------------------------------------------------
  // Function       : build_phase 
  // Return Type    : bit [7:0 ] - return type of function
  //                  continue with rt
  // Arguments      : uvm_phase phase - arguments
  // Description    : This phase creates all the required objects
  //-------------------------------------------------------------------------------
  virtual function bit [7:0 ] build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  //-------------------------------------------------------------------------------
  // Task           : run_phase 
  // Arguments      : uvm_phase phase 
  // Description    : In this phase the TB execution starts
  //-------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    
  endtask

endclass : test

`endif //TEST_SV




