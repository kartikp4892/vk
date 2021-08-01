//$INSERT_HEADER_HERE

`ifndef BASE_AGENT_SV
`define BASE_AGENT_SV

//--------------------------------------------------------------------
// Class       : base_agent
// Description : This is a base agent class for all the components.
//               This is the component from which all the UVC agents
//               will be extended and can be used. This components
//               have the common methods that all the agent 
//               components use. 
//--------------------------------------------------------------------
class base_agent #(type SEQUENCER = base_sequencer,
                   type DRIVER = base_driver,
                   type MONITOR = base_monitor,
                   type CONFIG = base_config) extends uvm_agent;

  typedef base_agent #(SEQUENCER, DRIVER, MONITOR, CONFIG) this_type;

  // Handle of the sequencer
  SEQUENCER m_sequencer;

  // Handle of the driver
  DRIVER m_driver;

  // Handle of the monitor
  MONITOR m_monitor;

  // Handle of the config
  CONFIG m_cfg;

  `uvm_component_param_utils_begin(this_type)
  `uvm_field_object(m_driver    , UVM_ALL_ON)
  `uvm_field_object(m_sequencer , UVM_ALL_ON)
  `uvm_field_object(m_monitor   , UVM_ALL_ON)
  `uvm_field_object(m_cfg       , UVM_ALL_ON)
  `uvm_component_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for base agent class.
  //------------------------------------------------------------------
  function new(string name ="base_agent",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : build_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which all the class objects are constructed 
  //-------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Get the configuration
    m_cfg = CONFIG::get_cfg(this, CONFIG::type_id::type_name);

    // If configuration is active then create the driver, sequencer, monitor
    if(is_active == UVM_ACTIVE) begin

      // Create the driver
      m_driver = DRIVER::type_id::create("m_driver",this);

      // Create the sequencer 
      m_sequencer = SEQUENCER::type_id::create("m_sequencer",this);

      // Create the monitor
      m_monitor = MONITOR::type_id::create("m_monitor",this);
    end//if(is_active == 

    // If configuration is passive then create only monitor
    else if(is_active == UVM_PASSIVE) begin

      // Create the monitor
      m_monitor = MONITOR::type_id::create("m_monitor",this);
    end//else if

  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : connect_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which various components connected
  //------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // If the configuration is set to ACTIVE, connect the sequencer and driver
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end//is_active
  endfunction :connect_phase 

endclass : base_agent

`endif // BASE_AGENT_SV












