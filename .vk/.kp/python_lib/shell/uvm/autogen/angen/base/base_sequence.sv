//$INSERT_HEADER_HERE

`ifndef BASE_SEQUENCE_SV
`define BASE_SEQUENCE_SV
//--------------------------------------------------------------------
// Class name  : base_sequence
// Description : This is a base sequence class. All other sequences
//               are derived from this sequence. 
//--------------------------------------------------------------------
class base_sequence#(type REQ = uvm_sequence_item) extends uvm_sequence#(REQ);

  `uvm_object_param_utils(base_sequence#(REQ))

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  // Description : Constructor for base sequence class.
  //------------------------------------------------------------------
  function new(string name="base_sequence");
    super.new(name);
  endfunction : new

  //--------------------------------------------------------------------
  // Defining virtual body method
  //--------------------------------------------------------------------
  virtual task body();
  endtask : body

  //--------------------------------------------------------------------
  // Defining virtual pre body method
  //--------------------------------------------------------------------
  virtual task pre_body();
    `uvm_info("pre_body",$psprintf("Entering the sequence %0s",get_name()), UVM_LOW)
  endtask : pre_body

  //--------------------------------------------------------------------
  // Defining virtual post body method
  //--------------------------------------------------------------------
  virtual task post_body();
    `uvm_info("post_body",$psprintf("Exiting the sequence %0s",get_name()), UVM_LOW)
  endtask : post_body

endclass : base_sequence

`endif // BASE_SEQUENCE_SV
