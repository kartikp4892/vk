//$INSERT_HEADER_HERE

`ifndef BASE_AGENT_SV
`define BASE_AGENT_SV

//--------------------------------------------------------------------
// Class name  : base_agent
// Description : This is a base agent class for all the components.
//               This is the component from which all the UVC agents
//               will be extended and can be used. This components
//               have the common methods that all the agent 
//               components use. 
//--------------------------------------------------------------------
class base_agent extends uvm_agent;

  //--------------------------------------------------------------------
  // Short hand macro registration 
  //--------------------------------------------------------------------
  `uvm_component_utils_begin(base_agent)
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
  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : connect_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which various components connected
  //------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction :connect_phase 

endclass : base_agent

`endif
