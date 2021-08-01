//$INSERT_HEADER_HERE

`ifndef BASE_TRANSACTION_SV
`define BASE_TRANSACTION_SV
//--------------------------------------------------------------------
// Class name  : base_transaction
// Description : This is a base transaction class. All other transactions
//               will be derived from this class. This class have all the
//               common methods that all other transaction.
//--------------------------------------------------------------------
class base_transaction extends uvm_sequence_item;

  // Transaction start time
  time trans_start_time;

  // Transaction stop time
  time trans_end_time;

  //-------------------------------------------------------------
  // UVM factory registration. 
  //-------------------------------------------------------------
  `uvm_object_utils_begin(base_transaction)
  `uvm_field_int (trans_start_time , UVM_ALL_ON | UVM_NOPACK | UVM_TIME)  
  `uvm_field_int (trans_end_time   , UVM_ALL_ON | UVM_NOPACK | UVM_TIME)  
  `uvm_object_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for base transaction class.
  //------------------------------------------------------------------
  function new(string name ="base_transaction");
    super.new(name);
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : do_print 
  // Arguments   : packer - handle of uvm_printer
  // Description : Method used to print diferent transaction variables. 
  //--------------------------------------------------------------------
  virtual function void do_print(uvm_printer printer );
    int verb_level = uvm_top.get_report_verbosity_level();

    if (printer.knobs.sprint==0) begin
      `uvm_info("do_print",$psprintf("%0s",convert2string()),UVM_LOW);
    end
    else if(verb_level >= UVM_HIGH) begin
      super.do_print(printer);
    end
    else begin
      printer.m_string = convert2string();
    end
  endfunction : do_print

  //--------------------------------------------------------------------
  // Method name : convert2string 
  // Description : This method must be overwritten in derived class.
  //--------------------------------------------------------------------
  virtual function string convert2string();
    `uvm_fatal("convert2string", 
               "This method must be overwritten in derived class and should not call super.convert2string.");
    return "";
  endfunction

endclass : base_transaction

`endif
