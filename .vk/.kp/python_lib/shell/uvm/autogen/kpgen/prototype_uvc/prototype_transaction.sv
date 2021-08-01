//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_TRANSACTION_SV
`define PROTOTYPE_TRANSACTION_SV

//---------------------------------------------------------------------------- 
// Class name  - prototype_transaction
// Description - This is the transaction class for prototype UVC. 
//---------------------------------------------------------------------------- 
class prototype_transaction extends base_transaction;

  //--------------------------------------------------------------------
  // Variables declarations
  //------------------------------------------------------------------
  
  //--------------------------------------------------------------------
  // UVM factory registration 
  //--------------------------------------------------------------------
  `uvm_object_utils_begin(prototype_transaction)
    // TODO : Register all the variables declared with the factory over here
  `uvm_object_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  // Description : Class constructor for prototype transaction.
  //--------------------------------------------------------------------
  function new(string name = "prototype_transaction");
    super.new(name);
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : do_compare 
  // Arguments   : rhs- is the variable of type uvm_object.
  //               comparer - is the object of the uvm_comparer
  // Description : Method in which we do the user defined comparision 
  //--------------------------------------------------------------------
  virtual function bit do_compare(uvm_object rhs,uvm_comparer comparer);
    prototype_transaction trans;

    // Cast the object type with transaction type
    if(!$cast(trans, rhs)) begin
     `uvm_error("do_compare","Incompatibale Types used in casting");
      return 0; 
    end//if(!$cast(trans, rhs)

   // TODO : Add the comparision over here

  endfunction : do_compare

  //--------------------------------------------------------------------
  // Method name : convert2string 
  // Description : This method return string with transaction variable values
  //--------------------------------------------------------------------
  virtual function string convert2string();
    string msg;
    
    // TODO - Update this to print required variables of the transaction with different transaction types.

    return msg;
  endfunction

endclass : prototype_transaction

`endif // PROTOTYPE_TRANSACTION_SV
