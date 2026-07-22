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

  // Override in a concrete sequence. start() invokes this via virtual
  // dispatch (class tasks resolve through %callt/virt).
  virtual task body();
  endtask

  // Bind sequencer and run body() on the dynamic type.
  task start(uvm_sequencer sqr);
    m_sequencer = sqr;
    body();
  endtask

  task start_item(uvm_sequence_item item);
  endtask

  task finish_item(uvm_sequence_item item);
    m_sequencer.put_item(item);
  endtask
endclass : uvm_sequence

// Accellera-shaped driver: pulls items from a bound sequencer. Override
// run_phase / drive_item in a concrete driver (virtual dispatch).
class uvm_driver extends uvm_component;
  uvm_sequencer seq_item_port;

  function new(string name = "uvm_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void set_sequencer(uvm_sequencer sqr);
    seq_item_port = sqr;
  endfunction

  task get_next_item(output uvm_sequence_item item);
    seq_item_port.get_next_item(item);
  endtask

  function void item_done();
    seq_item_port.item_done();
  endfunction

  // Override: process one item (default no-op).
  virtual task drive_item(uvm_sequence_item item);
  endtask

  // Override for multi-item loops; default pulls and drives one item.
  virtual task run_phase(uvm_phase phase);
    uvm_sequence_item item;
    phase.raise_objection(1);
    get_next_item(item);
    drive_item(item);
    item_done();
    phase.drop_objection(1);
  endtask
endclass : uvm_driver

// Accellera-shaped monitor: observation component with an analysis port.
class uvm_monitor extends uvm_component;
  uvm_analysis_port ap;

  function new(string name = "uvm_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap");
  endfunction

  // Override: sample DUT / produce an item and write to ap.
  virtual task sample_and_write(uvm_sequence_item item);
    ap.write(item);
  endtask
endclass : uvm_monitor

// Thin active agent: sequencer + driver + monitor under one component.
class uvm_agent extends uvm_component;
  bit is_active;
  uvm_sequencer sequencer;
  uvm_driver    driver;
  uvm_monitor   monitor;

  function new(string name = "uvm_agent", uvm_component parent = null);
    super.new(name, parent);
    is_active = 1;
  endfunction

  // super.build_phase / super.connect_phase are statically bound (no virt).
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = new("monitor", this);
    if (is_active) begin
      sequencer = new("sequencer", this);
      driver = new("driver", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active && driver != null && sequencer != null)
      driver.set_sequencer(sequencer);
  endfunction
endclass : uvm_agent

// Thin env: holds one agent (extend for multi-agent TBs).
class uvm_env extends uvm_component;
  function new(string name = "uvm_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass : uvm_env

`endif // IVL_UVM_SEQ_SVH
