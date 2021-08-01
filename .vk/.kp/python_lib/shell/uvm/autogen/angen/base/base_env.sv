//$INSERT_HEADER_HERE

`ifndef BASE_ENV_SV
`define BASE_ENV_SV

//--------------------------------------------------------------------
// Class name  : base_env 
// Description : This is a base environment class which has all the 
//               clock generation and reset methods which are used by
//               different components which are extended from this
//               class. 
//----------------------------------------------------------------
class base_env extends uvm_env;

  `uvm_component_utils(base_env)

  //--------------------------------------------------------------------
  // Method name : new
  // Arguments   : name - Name of the object.
  //               patent - parent component object.
  // Description : Constructor for base env class objects.
  //------------------------------------------------------------------
  function new(string name="base_env",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  //--------------------------------------------------------------------
  // Method name : build_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which all the class objects are constructed 
  //------------------------------------------------------------------
  protected virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  //--------------------------------------------------------------------
  // Method name : connect_phase 
  // Arguments   : phase - Handle of uvm_phase.
  // Description : The phase in which all the class objects are connected 
  //------------------------------------------------------------------
  protected virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  //--------------------------------------------------------------------
  // Method name : clk_gen 
  // Arguments   : clk_period - This is the variable based on which the
  //               Clock is generated.
  //               clk - The signal over which the clock is generated
  // Description : The method generates the clocks based on the input period
  //------------------------------------------------------------------
  protected virtual task clk_gen(time clk_period_ps,ref logic clk);
    `uvm_info("CLK_GEN",$psprintf("The Clock Period Generated : %t",clk_period_ps),UVM_LOW);

    // Initialize the value to logic 0
    clk = 0;

    // Generate the clock period
    begin : CLK_GEN
      forever begin
        #((clk_period_ps/2) * 1ps) clk = ~clk;
      end//forever
    end   : CLK_GEN
  endtask : clk_gen

  //--------------------------------------------------------------------
  // Method name : apply_reset_act_low 
  // Arguments   : rst - This is the variable over which the reset is applied
  // Description : The method applies reset to the variable which is active low
  //               by default the reset value of the signal is 1 and when reset
  //               is applied the value is zero
  //------------------------------------------------------------------
  protected virtual function void apply_reset_act_low(ref logic rst);
    `uvm_info("APPLY_RESET_ACT_LOW",$psprintf("The Reset is applied at time : %t",$realtime),UVM_LOW);

    // Apply reset to logic 0
    rst = 0;
  endfunction : apply_reset_act_low

  //--------------------------------------------------------------------
  // Method name : apply_reset_act_high 
  // Arguments   : rst - This is the variable over which the reset is applied
  // Description : The method applies reset to the variable which is active low
  //               by default the reset value of the signal is 0 and when reset
  //               is applied the value is 1
  //--------------------------------------------------------------------
  protected virtual function void apply_reset_act_high(ref logic rst);
    `uvm_info("APPLY_RESET_ACT_HIGH",$psprintf("The Reset is applied at time : %t",$realtime),UVM_LOW);

    // Apply reset to logic 1 
    rst = 1;
  endfunction : apply_reset_act_high

  //--------------------------------------------------------------------
  // Method name : apply_rst_fall_pulse 
  // Arguments   : rst - This is the variable over which the reset is applied
  //               rst_prd_ps - This is the variable for which the reset period
  //                            is set
  // Description : The method applies reset to the variable which is logic 1 
  //               by default, the reset value of the signal is 0 and when reset
  //               is applied then it is applied for a period of rst_prd_ps
  //--------------------------------------------------------------------
  protected virtual task apply_rst_fall_pulse(ref logic rst,time rst_prd_ps);
    `uvm_info("APPLY_RESET_FALL_PULSE",$psprintf("The Reset is applied at time : %t",$realtime),UVM_LOW);

    // Apply reset to logic 0 
    rst = 0;

    // Set thr reset to some period as per the requirement
    #(rst_prd_ps * 1ps);

    // Deassert the reset after some period 
    rst = 1;
  endtask : apply_rst_fall_pulse

  //--------------------------------------------------------------------
  // Method name : apply_rst_raise_pulse 
  // Arguments   : rst - This is the variable over which the reset is applied
  //               rst_prd_ps - This is the variable for which the reset period
  //                            is set
  // Description : The method applies reset to the variable which is logic 0 
  //               by default, the reset value of the signal is 1 and when reset
  //               is applied then it is applied for a period of rst_prd_ps
  //--------------------------------------------------------------------
  protected virtual task apply_rst_raise_pulse(ref logic rst,time rst_prd_ps);
    `uvm_info("APPLY_RESET_RAISE_PULSE",$psprintf("The Reset is applied at time : %t",$realtime),UVM_LOW);

    // Apply reset to logic 1 
    rst = 1;

    // Set thr reset to some period as per the requirement
    #(rst_prd_ps * 1ps);

    // Deassert the reset after some period 
    rst = 0;
  endtask : apply_rst_raise_pulse

endclass : base_env

`endif//BASE_ENV_SV
