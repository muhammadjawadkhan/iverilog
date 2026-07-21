`timescale 1ns/1ps
module phases_basic;
  import ivl_uvm_pkg::*;

  class leaf_comp extends uvm_component;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  endclass

  class demo_test extends uvm_test;
    leaf_comp leaf;
    int ran;
    function new(string name = "demo_test", uvm_component parent = null);
      super.new(name, parent);
      ran = 0;
    endfunction
    function void build_phase(uvm_phase phase);
      leaf = new("leaf", this);
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(1);
      #3;
      ran = 1;
      phase.drop_objection(1);
    endtask
  endclass

  demo_test t;
  uvm_objection o;
  uvm_phase ph;
  int pass;
  int n;
  int tot;

  initial begin
    pass = 1;

    o = new("obj");
    o.raise_objection(2);
    tot = o.get_objection_total();
    if (tot !== 2) begin $display("FAIL raise"); pass = 0; end
    o.drop_objection(2);
    tot = o.get_objection_total();
    if (tot !== 0) begin $display("FAIL drop"); pass = 0; end

    t = new("t", null);
    ph = new("build");
    t.build_phase(ph);
    n = t.get_num_children();
    if (n !== 1) begin $display("FAIL children=%0d", n); pass = 0; end

    ph = new("run");
    t.run_phase(ph);
    ph.wait_for_objections_drop();
    if (t.ran !== 1) begin $display("FAIL ran"); pass = 0; end
    tot = ph.get_objection_total();
    if (tot !== 0) begin $display("FAIL remain"); pass = 0; end

    if (pass) $display("PASSED");
    else $fatal(1, "phases_basic failed");
    $finish;
  end
endmodule
