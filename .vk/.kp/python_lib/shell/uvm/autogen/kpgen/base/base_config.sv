`ifndef BASE_CONFIG_SV
`define BASE_CONFIG_SV

//--------------------------------------------------------------------
// Class name  : base_config
// Description : This is a base configuration class, it has  the 
//              common variables used by the agent configuration
//--------------------------------------------------------------------
class base_config#(type obj = uvm_object) extends uvm_object;

  //Flag to disable all the checkers in monitor
  rand bit disable_all_check;

  //Verbosity to set for Less-Important(Debug type) print messages used the in
  uvm_verbosity verb_imp_msg_e;
  uvm_verbosity verb_dbg_msg_e;

  //--------------------------------------------------------------------
  // Short hand macro registration
  //-------------------------------------------------------------------
  `uvm_object_param_utils_begin(base_config#(obj))
  `uvm_field_int(disable_all_check,UVM_ALL_ON)
  `uvm_field_enum(uvm_verbosity,verb_dbg_msg_e, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_field_enum(uvm_verbosity,verb_imp_msg_e, UVM_ALL_ON | UVM_NOCOMPARE)
  `uvm_object_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  // Description : Constructor for agent configuration class objects.
  //------------------------------------------------------------------
  function new(string name = "base_config");
    super.new(name);
    verb_imp_msg_e = UVM_LOW;
    verb_dbg_msg_e = UVM_HIGH;
  endfunction : new

  //constarint to enable the checkers setting the flag to 0
  constraint c_disable_all_check{disable_all_check == 1'b0;};

  //--------------------------------------------------------------------
  // Method name : get_cfg
  // Arguments   : comp - instance of the uvm_component type.
  //               inst_name -String variable which is used to
  //               pass the string as a agrument in config db
  // Description : Method that returns the UVC configuration
  //--------------------------------------------------------------------
  static function obj get_cfg(uvm_component comp,string inst_name);

    //Handle of the object type to return 
    obj cfg;

    //get the configuration using the config_db method
    if((!(uvm_config_db #(obj)::get(comp,"",inst_name,cfg)))&&
       (cfg == null))begin
      `uvm_fatal(comp.get_name(),"Configuration is not received in the component");
      return null;
    end//if((!(uvm_config_db

    //return the configuration in the component that calls this mrthod
    return cfg;
  endfunction :  get_cfg

endclass : base_config 

`endif//BASE_CONFIG_SV





