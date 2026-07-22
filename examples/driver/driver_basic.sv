// Tier B smoke: uvm_driver + analysis port/subscriber + sequence.
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

  class my_driver extends uvm_driver;
    uvm_analysis_port ap;
    function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
      ap = new("ap");
    endfunction
    virtual task drive_item(uvm_sequence_item item);
      uvm_analysis_port p;
      p = ap;
      p.write(item);
    endtask
  endclass

  uvm_sequencer   sqr;
  my_seq          seq;
  my_driver       drv;
  scoreboard      sb;
  uvm_analysis_port ap;
  uvm_phase       ph;
  int             pass;

  initial begin
    pass = 1;
    sqr = new("sqr", null);
    seq = new("seq");
    drv = new("drv", null);
    sb = new("sb", null);
    drv.set_sequencer(sqr);
    ap = drv.ap;
    ap.connect(sb);

    // Producer then consumer (same thread; mailbox holds the item).
    seq.start(sqr);
    ph = new("run");
    drv.run_phase(ph);
    ph.wait_for_objections_drop();

    if (sb.seen !== 1 || sb.last_data !== 77) begin
      $display("FAIL: seen=%0d data=%0d", sb.seen, sb.last_data);
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "driver_basic failed");
    $finish;
  end
endmodule
