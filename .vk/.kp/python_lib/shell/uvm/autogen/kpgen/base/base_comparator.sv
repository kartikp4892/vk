`ifndef BASE_COMPARATOR
`define BASE_COMPARATOR

//-------------------------------------------------------------------------------
// Class          : base_comparator
// Parent         : uvm_scoreboard
// Parameters     : type ITEM 
//                  string ID 
// Description    : Base class for all scoreboards
//-------------------------------------------------------------------------------
//`include "base_macros.svh"
class base_comparator #(type ITEM, string ID) extends uvm_component;

  // Typedef     : this_type
  // Description : Type declaration of base comparator
  typedef base_comparator #(ITEM,ID) this_type;

  `uvm_component_param_utils(this_type)

  // Variable    : m_exp_export
  // Description : Analysis export for expected transactions
  uvm_analysis_export #(ITEM) m_exp_export;

  // Variable    : m_act_export
  // Description : Analysis export for actual transactions
  uvm_analysis_export #(ITEM) m_act_export;

  // Variable    : m_exp_fifo
  // Description : Analysis fifo for storing the expected transactions
  uvm_tlm_analysis_fifo #(ITEM) m_exp_fifo;

  // Variable    : m_act_fifo
  // Description : Analysis fifo for storing the actual transactions
  uvm_tlm_analysis_fifo #(ITEM) m_act_fifo;

  // Variable    : m_matches
  // Description : Indicates number of matches
  bit [31:0] m_matches;

  // Variable    : m_mismatches
  // Description : Indicates number of mismatches
  bit [31:0] m_mismatches;

  // Variable    : comp_id
  // Description : The comparison id used in report messages
  string comp_id;

  //-------------------------------------------------------------------------------
  // Function       : new
  // Arguments      : string name  - Name of the object.
  //                  uvm_component parent  - Object of parent component class.
  // Description    : Constructor for creating this class object
  //-------------------------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);

    m_exp_fifo = new ("m_exp_fifo", this);
    m_act_fifo = new ("m_act_fifo", this);

    m_exp_export = new ("m_exp_export", this);
    m_act_export = new ("m_act_export", this);

    if (ID == "") begin 
      comp_id = get_name();
    end
    else begin 
      comp_id = ID;
    end
  endfunction

  //-------------------------------------------------------------------------------
  // Function       : build_phase
  // Arguments      : uvm_phase phase  - Handle of uvm_phase.
  // Description    : This phase creates all the required objects
  //-------------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  //-------------------------------------------------------------------------------
  // Function       : connect_phase
  // Arguments      : uvm_phase phase  - Handle of uvm_phase.
  // Description    : This phase establish the connections between different component
  //-------------------------------------------------------------------------------
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    m_exp_export.connect(m_exp_fifo.analysis_export);
    m_act_export.connect(m_act_fifo.analysis_export);
  endfunction : connect_phase

  //-------------------------------------------------------------------------------
  // Function       : report_phase
  // Arguments      : uvm_phase phase  - Handle of uvm_phase.
  // Description    : Report the leftover transaction in base comparator
  //-------------------------------------------------------------------------------
  function void report_phase(uvm_phase phase);
    uvm_report_info(get_type_name(), $psprintf("Scoreboard Report %s", this.sprint()), UVM_LOW);

    // Report leftover transactions in expected fifo
    if(get_exp_fifo_size() != 0) begin
      `uvm_error(this.get_name(), $psprintf("Leftover transactions found in exp_fifo(%0d)",
                 m_exp_fifo.used()))

      /* while (get_exp_fifo_size() != 0) begin 
      ITEM exp_tx;

      m_exp_fifo.get(exp_tx);
      exp_tx.print();
      end
      */
    end

    // Report leftover transactions in actual fifo
    if(get_act_fifo_size() != 0) begin
      `uvm_error(this.get_name(), $psprintf("Leftover transactions found in act_fifo(%0d)",
                 m_act_fifo.used()))
      /*
      while (get_act_fifo_size() != 0) begin 
      ITEM act_tx;

      m_act_fifo.get(act_tx);
      act_tx.print();
      end
      */
    end
  endfunction : report_phase

  //-------------------------------------------------------------------------------
  // Task           : run_phase
  // Arguments      : uvm_phase phase  - Handle of uvm_phase.
  // Description    : In this phase the TB execution starts
  //-------------------------------------------------------------------------------
  task run_phase(uvm_phase phase);

    forever begin 
      ITEM exp_tx;
      ITEM act_tx;

      m_exp_fifo.get(exp_tx);
      m_act_fifo.get(act_tx);

      if (exp_tx.compare(act_tx)) begin
        `pass_msg(comp_id, $psprintf("EXP (%s) and ACT (%s) transactions match!!!", exp_tx.get_name(), act_tx.get_name()))
      end
      else begin 
        `fail_msg(comp_id, $psprintf("EXP (%s) and ACT (%s) transactions mismatch!!!", exp_tx.get_name(), act_tx.get_name()))
      end
    end
  endtask

  //-------------------------------------------------------------------------------
  // Function       : get_exp_fifo_size
  // Return Type    : unsigned int
  // Description    : Returns number of transactions left in expected fifo
  //-------------------------------------------------------------------------------
  virtual function int get_exp_fifo_size();
    return m_exp_fifo.used();
  endfunction : get_exp_fifo_size

  //-------------------------------------------------------------------------------
  // Function       : get_act_fifo_size
  // Return Type    : unsigned int
  // Description    : Returns number of transactions left in expected fifo
  //-------------------------------------------------------------------------------
  virtual function int get_act_fifo_size();
    return m_act_fifo.used();
  endfunction : get_act_fifo_size

  //-------------------------------------------------------------------------------
  // Function       : flush_fifo
  // Description    : Flush expected and actual fifo
  //-------------------------------------------------------------------------------
  virtual function void flush_fifo();
    m_exp_fifo.flush();
    m_act_fifo.flush();
  endfunction : flush_fifo

endclass : base_comparator

`endif //BASE_COMPARATOR







