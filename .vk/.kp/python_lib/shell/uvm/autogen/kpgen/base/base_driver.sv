//$INSERT_HEADER_HERE

`ifndef BASE_DRIVER_SV
`define BASE_DRIVER_SV

//--------------------------------------------------------------------
// Class name  : base_driver
// Description : This is a base driver class for all the components.
//               This is the component from which all the UVC drivers
//               will be extended and can be used. This components
//               have the common methods that all the driver
//               components use.
//--------------------------------------------------------------------
class base_driver#(type REQ = base_transaction,
                   type CONFIG = base_config) extends uvm_driver#(REQ);

  typedef base_driver #(REQ, CONFIG) this_type;

  // Event used to trigger at the start of driving the packet
  // on interface
  uvm_event#(REQ) m_start_drv_event;

  // Event used to trigger at the start of driving the data
  // on interface
  uvm_event#(REQ) m_start_drv_data_event;

  // Event used to trigger at the start of driving the data
  // on interface
  uvm_event#(REQ) m_start_drv_addr_event;

  // Event used to trigger after the complete packet is sent
  // on interface
  uvm_event#(REQ) m_end_drv_trans_event;

  //--------------------------------------------------------------------
  // Object declarations
  //--------------------------------------------------------------------
  protected CONFIG m_cfg;

  `uvm_component_param_utils_begin(this_type)
  `uvm_field_event(m_start_drv_event      , UVM_ALL_ON)
  `uvm_field_event(m_start_drv_data_event , UVM_ALL_ON)
  `uvm_field_event(m_start_drv_addr_event , UVM_ALL_ON)
  `uvm_field_event(m_end_drv_trans_event, UVM_ALL_ON)
  `uvm_field_object(m_cfg , UVM_ALL_ON)
  `uvm_component_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for base driver class.
  //------------------------------------------------------------------
  function new(string name ="base_driver",uvm_component parent);
    super.new(name,parent);

    // Create the events that are used in child components
    m_start_drv_event       = new("m_start_drv_event");
    m_start_drv_data_event  = new("m_start_drv_data_event");
    m_start_drv_addr_event  = new("m_start_drv_addr_event");
    m_end_drv_trans_event   = new("m_end_drv_trans_event");
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : build_phase
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which all the class objects are constructed
  //-------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the configuration variable from top level hierechy
    assert($cast (m_cfg , CONFIG::get_cfg(this, CONFIG::type_id::type_name)));
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

endclass : base_driver

`endif





