//$INSERT_HEADER_HERE

`ifndef BASE_SEQUENCER_SV
`define BASE_SEQUENCER_SV

//--------------------------------------------------------------------
// Class name  : base_sequencer
// Description : This is a base sequencer class for all the components.
//               This is the component from which all the UVC sequencers
//               will be extended and can be used. This components
//               have the common methods that all the sequencer 
//               components use. 
//--------------------------------------------------------------------
class base_sequencer#(type REQ = uvm_sequence_item) extends uvm_sequencer#(REQ);

  `uvm_component_param_utils(base_sequencer#(REQ))

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for base sequencer class.
  //------------------------------------------------------------------
  function new(string name ="base_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : build_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which all the class objects are constructed 
  //-------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : run_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which the component execution begins
  //------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase

endclass : base_sequencer

`endif
