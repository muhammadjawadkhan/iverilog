// Tier B — Accellera-shaped objections.
`ifndef IVL_UVM_PHASES_SVH
`define IVL_UVM_PHASES_SVH

`ifndef IVL_UVM_MAX_CHILDREN
  `define IVL_UVM_MAX_CHILDREN 32
`endif

class uvm_objection extends uvm_object;
  int m_count;

  function new(string name = "uvm_objection");
    super.new(name);
    m_count = 0;
  endfunction

  function void raise_objection(int count = 1);
    m_count = m_count + count;
  endfunction

  function void drop_objection(int count = 1);
    m_count = m_count - count;
    if (m_count < 0)
      m_count = 0;
  endfunction

  function int get_objection_total();
    return m_count;
  endfunction

  task wait_for_total_count(int count);
    while (m_count > count)
      #1;
  endtask
endclass : uvm_objection

`endif // IVL_UVM_PHASES_SVH
