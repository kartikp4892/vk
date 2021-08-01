//$INSERT_HEADER_HERE

`ifndef PROTOTYPE_DRIVER_SV
`define PROTOTYPE_DRIVER_SV

//----------------------------------------------------------------
// Class name  : prototype_driver
// Description : This is the drivr class of the prototype agent. 
//----------------------------------------------------------------
class prototype_driver#(type REQ = prototype_transaction) extends
  base_driver#(.REQ (REQ),
               .CONFIG (prototype_config));

  typedef prototype_driver #(REQ) this_type;

  //--------------------------------------------------------------------
  // Interface declarations
  //--------------------------------------------------------------------
  protected virtual interface prototype_if.driver_mp m_vif;

  //--------------------------------------------------------------------
  // Variable declarations
  //--------------------------------------------------------------------

  //---------------------------------------------------------------
  // UVM factory registration 
  //---------------------------------------------------------------
  `uvm_component_param_utils_begin(this_type)
  `uvm_component_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for prototype driver class.
  //-------------------------------------------------------------------
  function new(string name = "prototype_driver",uvm_component parent);
    super.new(name,parent);     
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : build_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : This phase creates all the  of prototype agent 
  //-------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info("build_phase","build phase of driver",m_cfg.verb_dbg_msg_e);

    // If interface is null, then it is not received from the top level hirerchey
    if((!uvm_config_db#(virtual prototype_if)::get(this, "", "prototype_if",m_vif)) 
       && (m_vif == null)) begin 

      `uvm_fatal("build_phase","Prototype interface is not received in the driver"); 
    end // if
  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : drive_pkt 
  // Arguments   : trans - Handle of the transaction type.
  // Description : The method has the logic to drive the packet on the
  //               interface as per the protocol
  //--------------------------------------------------------------------
  virtual task drive_pkt(REQ trans);

    // Print the transaction 
    `uvm_info("drive_pkt",$psprintf("Transaction Received from the sequencer is : \n%0s", 
                                    trans.sprint()),m_cfg.verb_imp_msg_e);

    // TODO : Add the logic to drive the packet on the interface

  endtask : drive_pkt

  //-------------------------------------------------------------------
  // Method name : send_items 
  // Description : This task gets the item from the sequencer and
  //               drives on the interface as per the protocol
  //-------------------------------------------------------------------
  virtual task send_items();
    forever begin 
      // Get the sequence item from the sequence item port
      seq_item_port.get_next_item(req);

      // Cast the request with the response packet
      $cast(rsp,req.clone());

      // Drive the packet on the interface       
      drive_pkt(rsp);

      // Set the id info for the request
      rsp.set_id_info(req);

      // Send the item_done to the prototype_sequencer
      seq_item_port.item_done(rsp);
    end
  endtask : send_items

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

    // TODO : Reset all the local variables and interface signals 

    // Wait for reset to be deasserted
    @(posedge m_vif.reset_f);
    `uvm_info("wait_for_reset","Reset is Deasserted",m_cfg.verb_dbg_msg_e)
  endtask : wait_for_reset

  //--------------------------------------------------------------------
  // Method name : run_phase 
  // Arguments   : phase - Handle of the uvm_phase.
  // Description : The phase in which the TB execution starts
  //               This phase collects the transaction from the 
  //               sequence item port and send the transaction on
  //               interface
  //-------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin 
      // Wait for the reset to be de-asserted
      wait_for_reset();
      fork 
        send_items();

        begin : EXIT_ON_RESET
          @(negedge m_vif.reset_f);
        end : EXIT_ON_RESET
      join_any
      disable fork;
    end

  endtask : run_phase

endclass : prototype_driver  


`endif // PROTOTYPE_DRIVER_SV





