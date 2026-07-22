// Tier B — Accellera-shaped sequences vertical slice.
//
// Items travel through a package-level mailbox#(uvm_sequence_item). Mailbox
// arrays and class-handle queues are unsupported; one shared channel is enough
// for the smoke slice (document multi-sequencer as a gap).
`ifndef IVL_UVM_SEQ_SVH
`define IVL_UVM_SEQ_SVH

mailbox #(uvm_sequence_item) ivl_uvm_seq_mbx;

class uvm_sequencer extends uvm_component;
  function new(string name = "uvm_sequencer", uvm_component parent = null);
    super.new(name, parent);
    if (ivl_uvm_seq_mbx == null)
      ivl_uvm_seq_mbx = new;
  endfunction

  task put_item(uvm_sequence_item item);
    mailbox #(uvm_sequence_item) mb;
    mb = ivl_uvm_seq_mbx;
    mb.put(item);
  endtask

  task get_next_item(output uvm_sequence_item item);
    mailbox #(uvm_sequence_item) mb;
    mb = ivl_uvm_seq_mbx;
    mb.get(item);
  endtask

  function void item_done();
  endfunction
endclass : uvm_sequencer

class uvm_sequence extends uvm_object;
  uvm_sequencer m_sequencer;

  function new(string name = "uvm_sequence");
    super.new(name);
  endfunction

  // Override in a concrete sequence. Call body() on a *derived* handle —
  // Icarus does not dispatch virtual methods, so start() does not invoke body().
  task body();
  endtask

  // Bind sequencer only. TB must then call body() via a concrete static type.
  task start(uvm_sequencer sqr);
    m_sequencer = sqr;
  endtask

  task start_item(uvm_sequence_item item);
  endtask

  task finish_item(uvm_sequence_item item);
    uvm_sequencer s;
    s = m_sequencer;
    s.put_item(item);
  endtask
endclass : uvm_sequence

`endif // IVL_UVM_SEQ_SVH
