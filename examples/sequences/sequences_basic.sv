// Tier B smoke: sequence start/body → sequencer → get_next_item.
`timescale 1ns/1ps

module sequences_basic;
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
    task body();
      my_item it;
      uvm_sequencer s;
      it = new("it0");
      it.data = 99;
      // Inline put (avoid inherited-method lookup gaps).
      s = m_sequencer;
      s.put_item(it);
    endtask
  endclass

  uvm_sequencer sqr;
  my_seq        seq;
  uvm_sequence_item got;
  my_item       mi;
  bit           ok;
  int           pass;

  initial begin
    pass = 1;
    sqr = new("sqr", null);
    seq = new("seq");

    seq.start(sqr);
    seq.body();
    sqr.get_next_item(got);
    ok = $cast(mi, got);
    if (!ok || mi.data !== 99) begin
      $display("FAIL: got data ok=%0b", ok);
      pass = 0;
    end
    sqr.item_done();

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "sequences_basic failed");
    $finish;
  end
endmodule
