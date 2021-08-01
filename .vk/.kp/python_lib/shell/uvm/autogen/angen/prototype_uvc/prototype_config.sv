//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_CONFIG_SV
`define PROTOTYPE_CONFIG_SV

//--------------------------------------------------------------------
// Class name  : prototype_config
// Description : This is a configuration class for prototype agent,
//               it holds the variables that are required for different
//               configurations of prototype UVC. 
//--------------------------------------------------------------------
class prototype_config extends base_config#(prototype_config);

  //--------------------------------------------------------------------
  // Variables declarations
  //-----------------------------------------------------------------
  // Variable to enable/disable the checker coverage
  // Default : Enable -> 1
  // Disable -> 0
  bit en_checker_cov = 1;

  // Constraint for checker coverage
  constraint c_en_chk_cov {
    soft en_checker_cov == 1;
  }

  //--------------------------------------------------------------------
  // UVM factory registration
  //-------------------------------------------------------------------
  `uvm_object_utils_begin(prototype_config)
  `uvm_field_int(en_checker_cov,UVM_ALL_ON)
  // TODO : Register all the local variables and objects.
  `uvm_object_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  // Description : Constructor for prototype agent configuration class objects.
  //------------------------------------------------------------------
  function new(string name="prototype_config");
    super.new(name);
  endfunction : new

endclass : prototype_config

`endif // PROTOTYPE_CONFIG_SV
