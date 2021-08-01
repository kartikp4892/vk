//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_SEQUENCER_SV
`define PROTOTYPE_SEQUENCER_SV

//----------------------------------------------------------------------------
// Class name  : prototype_sequencer
// Description : This is a sequencer class for the prototype.
//---------------------------------------------------------------------------
class prototype_sequencer extends base_sequencer#(prototype_transaction);

  //--------------------------------------------------------------------
  // UVM factory registration 
  //--------------------------------------------------------------------
  `uvm_component_utils_begin(prototype_sequencer)
  `uvm_component_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for prototype sequencer.
  //-------------------------------------------------------------------
  function new(string name ="prototype_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction : new

endclass : prototype_sequencer

`endif // PROTOTYPE_SEQUENCER_SV
