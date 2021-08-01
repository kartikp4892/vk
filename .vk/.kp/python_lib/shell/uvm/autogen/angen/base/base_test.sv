//$INSERT HEADER HERE
`ifndef BASE_TEST_SV
`define BASE_TEST_SV

//--------------------------------------------------------------------
// Class name  : base_test
// Description : This is a base test class.
//--------------------------------------------------------------------

class base_test extends uvm_test;

  int uvm_error_cnt;
  int uvm_info_cnt;
  int uvm_fatal_cnt;


  `uvm_component_utils_begin(base_test)
  `uvm_field_int(uvm_error_cnt,UVM_ALL_ON | UVM_NOPRINT)
  `uvm_field_int(uvm_info_cnt,UVM_ALL_ON | UVM_NOPRINT)
  `uvm_field_int(uvm_fatal_cnt,UVM_ALL_ON | UVM_NOPRINT)
  `uvm_component_utils_end

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for base class.
  //------------------------------------------------------------------
  function new(string name = "",uvm_component parent);
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
  // Description : The phase in which we have varrious connections.
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  //--------------------------------------------------------------------
  // Method name : run_phase
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which the  execution begins
  //------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase


  virtual function void check_phase(uvm_phase phase);
    uvm_report_server server;
    super.check_phase(phase);
    //Get the server of UVM
    server = uvm_report_server::get_server();
    uvm_info_cnt = server.get_severity_count(UVM_INFO);
    uvm_error_cnt = server.get_severity_count(UVM_ERROR);
    uvm_fatal_cnt = server.get_severity_count(UVM_FATAL);
  endfunction : check_phase

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    if(uvm_error_cnt != 0 || uvm_fatal_cnt != 0) begin
      $display("=======================================================================");
      $display("                                                                       ");
      $display("               ##########   ########   #######   #                     ");
      $display("               #           #        #     #      #                     ");
      $display("               #           #        #     #      #                     ");
      $display("               #           #        #     #      #                     ");
      $display("               ##########  ##########     #      #                     ");
      $display("               #           #        #     #      #                     ");
      $display("               #           #        #     #      #                     ");
      $display("               #           #        #     #      #                     ");
      $display("               #           #        #  #######   #######               ");
      $display("                                                                       ");
      $display("=======================================================================");
    end else begin

      $display("=======================================================================");
      $display("                                                                       ");
      $display("              #########    ########   ########  ########               ");
      $display("              #        #  #        #  #         #                      ");
      $display("              #        #  #        #  #         #                      ");
      $display("              #        #  #        #  #         #                      ");
      $display("              #########   ##########  ########  ########               ");
      $display("              #           #        #         #         #               ");
      $display("              #           #        #         #         #               ");
      $display("              #           #        #         #         #               ");
      $display("              #           #        #  ########  ########               ");
      $display("                                                                       ");
      $display("=======================================================================");
    end
  endfunction : report_phase

endclass : base_test

`endif




