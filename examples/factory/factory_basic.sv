// Tier B #1 smoke: uvm_object_registry#(T) auto-register + create / override.
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

  // Module-level typedefs of the Accellera-shaped registry (nested
  // `TYPE::type_id` scope resolution is not supported yet).
  typedef uvm_object_registry#(pkt, "pkt")         pkt_type_id;
  typedef uvm_object_registry#(pkt_ext, "pkt_ext") pkt_ext_type_id;

  pkt_type_id        w_pkt;
  pkt_ext_type_id    w_ext;
  uvm_factory        f;
  uvm_object         obj;
  pkt                p;
  pkt_ext            pe;
  uvm_object_wrapper found;
  bit                ok;
  int                pass;
  string             actual;

  initial begin
    pass = 1;

    // Construction auto-registers with the factory.
    w_pkt = new;
    w_ext = new;
    f = uvm_get_factory();

    obj = f.create_object_by_name("pkt", "", "p0");
    ok = $cast(p, obj);
    if (!ok || p.kind !== 1) begin
      $display("FAIL: create pkt ok=%0b", ok);
      pass = 0;
    end

    // Also exercise wrapper.create directly.
    p = w_pkt.create("p0b");
    if (p == null || p.kind !== 1) begin
      $display("FAIL: type_id.create");
      pass = 0;
    end

    f.set_type_override_by_name("pkt", "pkt_ext");
    actual = f.resolve_type_name("pkt");
    if (actual != "pkt_ext") begin
      $display("FAIL: resolve got '%s'", actual);
      pass = 0;
    end

    obj = f.create_object_by_name("pkt", "", "p1");
    ok = $cast(pe, obj);
    if (!ok || pe.kind !== 2) begin
      $display("FAIL: override create ok=%0b", ok);
      pass = 0;
    end

    found = f.find_by_name("pkt");
    if (found == null) begin
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
