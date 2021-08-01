//$INSERT_HEADER_HERE

`ifndef BASE_MONITOR_SV
`define BASE_MONITOR_SV

//--------------------------------------------------------------------
// Class name  : base_monitor
// Description : This is a base monitor class for all the components.
//               This is the component from which all the UVC monitors
//               will be extended and can be used. This components
//               have the common methods that all the monitor 
//               components use. 
//--------------------------------------------------------------------
class base_monitor#(type REQ = uvm_sequence_item, type RSP = REQ) extends uvm_monitor;

  // Event used before the start of sampling the frame
  uvm_event#(REQ) m_start_samp_event;

  // Event used after the end of collecting the addr 
  uvm_event#(REQ) m_end_samp_addr_event;

  // Event used after the end of collecting the data 
  uvm_event#(REQ) m_end_samp_data_event;

  // Event used after the end of collecting the complete transaction 
  uvm_event#(REQ) m_end_samp_trans_event;

  `uvm_component_param_utils_begin(base_monitor#(REQ))
  `uvm_field_event(m_start_samp_event     , UVM_ALL_ON)
  `uvm_field_event(m_end_samp_addr_event  , UVM_ALL_ON)
  `uvm_field_event(m_end_samp_data_event  , UVM_ALL_ON)
  `uvm_field_event(m_end_samp_trans_event , UVM_ALL_ON)
  `uvm_component_utils_end


  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for base driver class.
  //-----------------------------------------------------------------
  function new(string name ="base_monitor",uvm_component parent);
    super.new(name,parent);

    // Create all the events that are used in sampling the transaction
    m_start_samp_event     = new("m_start_samp_event");
    m_end_samp_addr_event  = new("m_end_samp_addr_event");
    m_end_samp_data_event  = new("m_end_samp_data_event");
    m_end_samp_trans_event = new("m_end_samp_trans_event");
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
  // Method name : connect_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which we have varrious connections of the
  //              varrious components connected.
  //------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  //--------------------------------------------------------------------
  // Method name : run_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which the component execution begins
  //------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase

endclass : base_monitor

`endif
