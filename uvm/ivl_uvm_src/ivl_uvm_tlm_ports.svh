// Tier B — Accellera-shaped TLM put/get for int payloads.
//
// Uses an int queue (class-handle queues and mailbox class properties are
// unsupported). Ports hold a concrete fifo handle and call with static types
// (no virtual method dispatch required).
`ifndef IVL_UVM_TLM_PORTS_SVH
`define IVL_UVM_TLM_PORTS_SVH

class uvm_tlm_fifo;
  int m_q[$];

  function new(string name = "uvm_tlm_fifo");
  endfunction

  task put(int val);
    m_q.push_back(val);
  endtask

  task get(output int val);
    while (m_q.size() == 0)
      #1;
    val = m_q[0];
    void'(m_q.pop_front());
  endtask

  // Functions cannot use output ports on this compiler — use get() or size().
  function int can_get();
    return (m_q.size() != 0);
  endfunction

  function int size();
    return m_q.size();
  endfunction

  function bit is_empty();
    return (m_q.size() == 0);
  endfunction
endclass : uvm_tlm_fifo

class uvm_blocking_put_port;
  uvm_tlm_fifo m_imp;

  function new(string name = "uvm_blocking_put_port");
  endfunction

  function void connect(uvm_tlm_fifo imp);
    m_imp = imp;
  endfunction

  task put(int val);
    uvm_tlm_fifo f;
    f = m_imp;
    f.put(val);
  endtask
endclass : uvm_blocking_put_port

class uvm_blocking_get_port;
  uvm_tlm_fifo m_imp;

  function new(string name = "uvm_blocking_get_port");
  endfunction

  function void connect(uvm_tlm_fifo imp);
    m_imp = imp;
  endfunction

  task get(output int val);
    uvm_tlm_fifo f;
    f = m_imp;
    f.get(val);
  endtask

  function int can_get();
    uvm_tlm_fifo f;
    f = m_imp;
    return f.can_get();
  endfunction
endclass : uvm_blocking_get_port

// Analysis: single-subscriber smoke (no subscriber queues / AAs of handles).
// Connect one uvm_subscriber; write() dispatches virtually.
class uvm_subscriber extends uvm_component;
  function new(string name = "uvm_subscriber", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void write(uvm_sequence_item t);
  endfunction
endclass : uvm_subscriber

class uvm_analysis_port;
  uvm_subscriber m_imp;

  function new(string name = "uvm_analysis_port");
  endfunction

  function void connect(uvm_subscriber imp);
    m_imp = imp;
  endfunction

  function void write(uvm_sequence_item t);
    if (m_imp != null)
      m_imp.write(t);
  endfunction
endclass : uvm_analysis_port

`endif // IVL_UVM_TLM_PORTS_SVH
