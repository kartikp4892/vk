//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_AGENT_SV
`define PROTOTYPE_AGENT_SV

//----------------------------------------------------------------------
// Class name  : prototype_agent
// Description : This is a agent class having the instances of prototype
//               driver, prototype sequencer and prototype monitor.
//               The agent can be configured as either ACTIVE or PASSIVE.
//----------------------------------------------------------------------
class prototype_agent extends 
  base_agent #(.SEQUENCER (prototype_sequencer),
               .DRIVER    (prototype_driver),
               .MONITOR   (prototype_monitor),
               .CONFIG    (prototype_config));

  // UVM factory registraction
  `uvm_component_utils_begin(prototype_agent)
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

  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : connect_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : This phase establish the connections between different
  //               prototype agent components.
  //--------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

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

`endif //PROTOTYPE_AGENT_SV





