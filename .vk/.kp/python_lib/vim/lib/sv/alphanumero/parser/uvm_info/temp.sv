`ifndef TEMP_SV
`define TEMP_SV

class temp extends uvm_component;
  
  `uvm_component_utils (temp)

  function new(string name, uvm_component parent = null);
    super.new(name,parent);

    `uvm_info("new", $psprintf("Hello", ),UVM_LOW)
    `uvm_warning(get_full_name(), "waring")
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("build_phase", $psprintf("What'su up", ),UVM_LOW)
    `uvm_fatal(get_full_name(), "Hello")
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    `uvm_info("run_phase", $psprintf("He", ),UVM_LOW)
    `uvm_error(get_full_name(), "'hi'")
  endtask

endclass : temp

`endif //TEMP_SV




