//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_SEQUENCES_SV
`define PROTOTYPE_SEQUENCES_SV

//--------------------------------------------------------------------
// Class name  : prototype_base_seq
// Description : This is a base sequence class for prototype UVC. 
//               All the UVC sequences will be extended from this
//               sequence. This sequence have the common methods 
//               to be used by other derived sequences.
//--------------------------------------------------------------------
class prototype_base_seq extends base_sequence#(prototype_transaction);

  `uvm_object_utils(prototype_base_seq)

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  // Description : Constructor for base sequence class.
  //------------------------------------------------------------------
  function new(string name="prototype_base_seq");
    super.new(name);
  endfunction : new
   
  //--------------------------------------------------------------------
  // Defining virtual body method
  //--------------------------------------------------------------------
  virtual task body();
  endtask : body
   
endclass : prototype_base_seq

 // TODO : Add all the sequences over here extended from prototype_base_seq

`endif // PROTOTYPE_SEQUENCES_SV
