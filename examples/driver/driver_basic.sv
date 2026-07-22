// Tier B smoke: uvm_driver + analysis fan-out (multi-subscriber) + sequence.
`timescale 1ns/1ps

module driver_basic;
  import ivl_uvm_pkg::*;

  class my_item extends uvm_sequence_item;
    function new(string name = "my_item");
      super.new(name);
    endfunction
  endclass

  class my_seq extends uvm_sequence;
    function new(string name = "my_seq");
      super.new(name);
    endfunction
    virtual task body();
      my_item it;
      it = new("it0");
      it.data = 77;
      start_item(it);
      finish_item(it);
    endtask
  endclass

  class scoreboard extends uvm_subscriber;
    int last_data;
    int seen;
    function new(string name = "scoreboard", uvm_component parent = null);
      super.new(name, parent);
      last_data = 0;
      seen = 0;
    endfunction
    virtual function void write(uvm_sequence_item t);
      my_item mi;
      bit ok;
      ok = $cast(mi, t);
      if (ok) begin
        last_data = mi.data;
        seen = 1;
      end
    endfunction
  endclass

  class coverage extends uvm_subscriber;
    int hits;
    function new(string name = "coverage", uvm_component parent = null);
      super.new(name, parent);
      hits = 0;
    endfunction
    virtual function void write(uvm_sequence_item t);
      hits = hits + 1;
    endfunction
  endclass

  class my_driver extends uvm_driver;
    uvm_analysis_port ap;
    function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap");
    endfunction
    virtual task drive_item(uvm_sequence_item item);
      ap.write(item);
    endtask
  endclass

  uvm_sequencer   sqr;
  my_seq          seq;
  my_driver       drv;
  scoreboard      sb;
  coverage        cov;
  uvm_phase       ph;
  int             pass;

  initial begin
    pass = 1;
    sqr = new("sqr", null);
    seq = new("seq");
    drv = new("drv", null);
    sb = new("sb", null);
    cov = new("cov", null);
    drv.set_sequencer(sqr);
    drv.ap.connect(sb);
    drv.ap.connect(cov);

    // Producer then consumer (same thread; mailbox holds the item).
    seq.start(sqr);
    ph = new("run");
    drv.run_phase(ph);
    ph.wait_for_objections_drop();

    if (drv.ap.size() !== 2) begin
      $display("FAIL: ap.size=%0d", drv.ap.size());
      pass = 0;
    end
    if (sb.seen !== 1 || sb.last_data !== 77) begin
      $display("FAIL: sb seen=%0d data=%0d", sb.seen, sb.last_data);
      pass = 0;
    end
    if (cov.hits !== 1) begin
      $display("FAIL: cov hits=%0d", cov.hits);
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "driver_basic failed");
    $finish;
  end
endmodule
