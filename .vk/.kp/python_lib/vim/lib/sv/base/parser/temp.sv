`ifndef TEMP_SV
`defind TEMP_SV


/****
   function void trace(uvm_object obj = null);
      if (m_cb != null && T::cbs::get_debug_flags() & UVM_CALLBACK_TRACE) begin
         uvm_report_object reporter = null;
         string who = "Executing ";
         void'($cast(reporter, obj));
         if (reporter == null) void'($cast(reporter, m_obj));
         if (reporter == null) reporter = uvm_top;
         if (obj != null) who = {obj.get_full_name(), " is executing "};
         else if (m_obj != null) who = {m_obj.get_full_name(), " is executing "};
         reporter.uvm_report_info("CLLBK_TRC", {who, "callback ", m_cb.get_name()}, UVM_LOW);
      end
   endfunction
****/
class uvm_callback extends uvm_object;

  static uvm_report_object reporter = new("cb_tracer");

  protected bit m_enabled = 1;

  // Function: new
  //
  // Creates a new uvm_callback object, giving it an optional ~name~.

  function new(string name="uvm_callback");
    super.new(name);
  endfunction


  // Function: callback_mode
  //
  // Enable/disable callbacks (modeled like rand_mode and constraint_mode).

  function bit callback_mode(int on=-1);
    if(on == 0 || on == 1) begin
      `uvm_cb_trace_noobj(this,$sformatf("Setting callback mode for %s to %s",
            get_name(), ((on==1) ? "ENABLED":"DISABLED")))
    end
    else begin
      `uvm_cb_trace_noobj(this,$sformatf("Callback mode for %s is %s",
            get_name(), ((m_enabled==1) ? "ENABLED":"DISABLED")))
    end
    callback_mode = m_enabled;
    if(on==0) m_enabled=0;
    if(on==1) m_enabled=1;
  endfunction


  // Function: is_enabled
  //
  // Returns 1 if the callback is enabled, 0 otherwise.

  function bit is_enabled();
    return callback_mode();
  endfunction

  static string type_name = "uvm_callback";


  // Function: get_type_name
  //
  // Returns the type name of this callback object.

  virtual function string get_type_name();
     return type_name;
  endfunction

endclass


`endif // UVM_CALLBACK_SVH


