//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_AGENT_SV
`define PROTOTYPE_AGENT_SV

//----------------------------------------------------------------------
// Class name  : prototype_agent
// Description : This is a agent class having the instances of prototype
//               driver, prototype sequencer and prototype monitor.
//               The agent can be configured as either ACTIVE or PASSIVE.
//----------------------------------------------------------------------
class prototype_agent extends base_agent;

  //--------------------------------------------------------------------
  // Components declarations
  //--------------------------------------------------------------------
  // Handle of the prototype driver
  prototype_driver m_driver;

  // Handle of the prototype sequencer 
  prototype_sequencer m_sequencer;

  // Handle of the prototype monitor 
  prototype_monitor m_monitor;

  // Handle of the prototype configurations
  prototype_config m_cfg;

  // UVM factory registraction
  `uvm_component_utils_begin(prototype_agent)
  `uvm_field_object(m_driver    , UVM_ALL_ON)
  `uvm_field_object(m_sequencer , UVM_ALL_ON)
  `uvm_field_object(m_monitor   , UVM_ALL_ON)
  `uvm_field_object(m_cfg       , UVM_ALL_ON)
  `uvm_component_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               parent - parent component object.
  // Description : Constructor for prototype agent class
  //--------------------------------------------------------------------
  function new(string name = "prototype_agent",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : build_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : This phase creates all the components of prototype agent 
  //--------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);

    // Calling the build method of the parent class
    super.build_phase(phase);

    // Get the configuration
    m_cfg = prototype_config::get_cfg(this,"prototype_config");

    // If configuration is active then create the driver, sequencer, monitor
    if(is_active == UVM_ACTIVE) begin

      // Create the prototype driver
      m_driver = prototype_driver#(prototype_transaction)::type_id::create("m_driver",this);

      // Create the prototype sequencer 
      m_sequencer = prototype_sequencer::type_id::create("m_sequencer",this);

      // Create the prototype monitor
      m_monitor = prototype_monitor#(prototype_transaction)::type_id::create("m_monitor",this);
    end//if(is_active == 

    // If configuration is passive then create only monitor
    else if(is_active == UVM_PASSIVE) begin

      // Create the prototype monitor
      m_monitor = prototype_monitor#(prototype_transaction)::type_id::create("m_monitor",this);
    end//else if

  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : connect_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : This phase establish the connections between different
  //               prototype agent components.
  //--------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // If the configuration is set to ACTIVE, connect the sequencer and driver
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end//is_active
  endfunction : connect_phase

  //---------------------------------------------------------------------------
  // Method      : end_of_elaboration 
  // Description : This method prints configuration.
  //---------------------------------------------------------------------------
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("end_of_elaboration",$sformatf("PROTOTYPE Configuration is: \n%0s",m_cfg.sprint()), m_cfg.verb_imp_msg_e)
  endfunction : end_of_elaboration_phase 
endclass : prototype_agent

`endif//PROTOTYPE_AGENT_SV
