//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_MONITOR_SV
`define PROTOTYPE_MONITOR_SV

//----------------------------------------------------------------------------
// Class name  : prototype_monitor
// Description : This is a monitor class for the prototype agent. This component
//               samples the data frmo the interface and create prototype 
//               transaction. It sends the sampled transaction on analysis
//               port. It also contain all the checkers required for prototype 
//               with coverage.
//----------------------------------------------------------------------------
class prototype_monitor#(type REQ = prototype_transaction) extends 
  base_monitor#(.REQ (REQ),
                .CONFIG (prototype_config));

  typedef prototype_monitor #(REQ) this_type;

  //--------------------------------------------------------------------------
  // Object declarations
  //-------------------------------------------------------------------------
  // Transaction handle used to collect the transaction
  protected REQ m_trans_collected;

  //--------------------------------------------------------------------
  // Analysis Port declarations
  //--------------------------------------------------------------------
  uvm_analysis_port #(REQ) item_collected_port;

  //--------------------------------------------------------------------
  // Interface declarations
  //--------------------------------------------------------------------
  protected virtual interface prototype_if.monitor_mp m_vif;

  //--------------------------------------------------------------------
  // Short hand macro registration 
  //--------------------------------------------------------------------
  `uvm_component_param_utils_begin(this_type)
    // TODO : Add all the local variables and objects over here to register them with factory
  `uvm_component_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for prototype class objects.
  //------------------------------------------------------------------
  function new(string name = "prototype_monitor",uvm_component parent);
    super.new(name,parent);

    // Create the analysis port
    item_collected_port = new("item_collected_port", this); 
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : build_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : This phase create all the required objects.
  //-------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

   `uvm_info("build_phase","In the build phase of monitor",m_cfg.verb_dbg_msg_e);

    // If interface is null, then it is not received from the top level hirerchey
    if((!uvm_config_db#(virtual prototype_if)::get(this, "", "prototype_if",m_vif)) && (m_vif == null)) begin
     `uvm_fatal("build_phase","The interface is not received in the prototype_monitor");
    end
  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : run_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : This phase samples interface and create transaction.
  //-------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    // Wait for the initial reset
    wait_for_reset();

    // Start the different threads to sample the interface and create transaction.
    forever begin
      fork
        fork
          begin : SAMPLE_PRTOTOTYPE_INTERFACE
            // TODO : Add the logic to sample the signals on interface
          end : SAMPLE_PRTOTOTYPE_INTERFACE

          begin : EXIT_ON_RESET
            //if reset is received then break the running threads
            @(negedge m_vif.reset_f);
          end : EXIT_ON_RESET
        join_any
        disable fork;
      join

      // Wait for reset
      wait_for_reset();
    end
  endtask : run_phase

  //--------------------------------------------------------------------
  // Method name : wait_for_reset 
  // Description : The method wait for the reset and initialize all the 
  //               interface and local variables when reset is asserted,
  //               and waits till reset is deasserted
  //--------------------------------------------------------------------
  virtual task wait_for_reset();
    // Wait for reset to be asserted
    wait(m_vif.reset_f == 0);
   `uvm_info("wait_for_reset","Reset is Asserted",m_cfg.verb_dbg_msg_e)

    // Wait for reset to be deasserted
    @(posedge m_vif.reset_f);
   `uvm_info("wait_for_reset","Reset is Deasserted",m_cfg.verb_dbg_msg_e)
  endtask : wait_for_reset

  //--------------------------------------------------------------------
  // Method name : write_transaction 
  // Arguments   : trans - Handle of prototype transaction.
  // Description : This method writes the transactions on the analysis 
  //               port. 
  //-------------------------------------------------------------------
  function void write_transaction(REQ trans);
    // Print the collected transaction
   `uvm_info("write_transaction",$psprintf("Transaction Collected in the monitor is : \n%0s", 
      trans.sprint()),m_cfg.verb_imp_msg_e);

    // Populate the transaction
    item_collected_port.write(trans);

  endfunction : write_transaction

endclass : prototype_monitor

`endif // PROTOTYPE_MONITOR_SV
