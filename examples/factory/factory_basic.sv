// Tier B #1 smoke: name-based factory register / resolve / create / override.
`timescale 1ns/1ps

module factory_basic;
  import ivl_uvm_pkg::*;

  class pkt extends uvm_object;
    int kind;
    function new(string name = "pkt");
      super.new(name);
      kind = 1;
    endfunction
    `ivl_uvm_object_utils(pkt)
  endclass

  class pkt_ext extends pkt;
    function new(string name = "pkt_ext");
      super.new(name);
      kind = 2;
    endfunction
    `ivl_uvm_object_utils(pkt_ext)
  endclass

  class pkt_wrapper extends uvm_object_wrapper;
    function new();
      super.new("pkt");
    endfunction
    function uvm_object create_object(string name = "");
      pkt o;
      o = new(name);
      return o;
    endfunction
  endclass

  class pkt_ext_wrapper extends uvm_object_wrapper;
    function new();
      super.new("pkt_ext");
    endfunction
    function uvm_object create_object(string name = "");
      pkt_ext o;
      o = new(name);
      return o;
    endfunction
  endclass

  function uvm_object make_by_name(uvm_factory fac, string requested, string name);
    string actual;
    uvm_object_wrapper w;
    pkt_wrapper pw;
    pkt_ext_wrapper pew;
    bit ok;
    actual = fac.resolve_type_name(requested);
    w = fac.find_by_name(actual);
    ok = $cast(pw, w);
    if (ok)
      return pw.create_object(name);
    ok = $cast(pew, w);
    if (ok)
      return pew.create_object(name);
    $display("UVM_ERROR @ 0: reporter [FCTTYP] Type '%s' not registered", actual);
    return null;
  endfunction

  pkt_wrapper        w_pkt;
  pkt_ext_wrapper    w_ext;
  uvm_factory        f;
  uvm_object         obj;
  pkt                p;
  pkt_ext            pe;
  uvm_object_wrapper found;
  pkt_wrapper        found_pkt;
  bit                ok;
  int                pass;
  string             actual;

  initial begin
    pass = 1;

    w_pkt = new;
    w_ext = new;
    f = uvm_get_factory();
    f.register(w_pkt);
    f.register(w_ext);

    obj = make_by_name(f, "pkt", "p0");
    ok = $cast(p, obj);
    if (!ok || p.kind !== 1) begin
      $display("FAIL: create pkt ok=%0b", ok);
      pass = 0;
    end

    f.set_type_override_by_name("pkt", "pkt_ext");
    actual = f.resolve_type_name("pkt");
    if (actual != "pkt_ext") begin
      $display("FAIL: resolve got '%s'", actual);
      pass = 0;
    end

    obj = make_by_name(f, "pkt", "p1");
    ok = $cast(pe, obj);
    if (!ok || pe.kind !== 2) begin
      $display("FAIL: override create ok=%0b", ok);
      pass = 0;
    end

    found = f.find_by_name("pkt");
    ok = $cast(found_pkt, found);
    if (!ok) begin
      $display("FAIL: find_by_name pkt");
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "factory_basic failed");
    $finish;
  end
endmodule
