// Compiler: class-handle property method calls (obj.prop.method and chains).
`timescale 1ns/1ps

class leaf;
  int x;
  function void setx(int v);
    x = v;
  endfunction
  function int getx();
    return x;
  endfunction
endclass

class mid;
  leaf ap;
  function new();
    ap = new;
  endfunction
endclass

class outer;
  mid m;
  leaf ap;
  function new();
    m = new;
    ap = new;
  endfunction
endclass

module property_methods_basic;
  outer o;
  int n;
  int pass;

  initial begin
    pass = 1;
    o = new;
    o.ap.setx(9);
    n = o.ap.getx();
    if (n !== 9) begin
      $display("FAIL one-level: got %0d", n);
      pass = 0;
    end
    o.m.ap.setx(11);
    n = o.m.ap.getx();
    if (n !== 11) begin
      $display("FAIL chain: got %0d", n);
      pass = 0;
    end
    if (pass)
      $display("PASSED");
    else
      $fatal(1, "property_methods_basic failed");
    $finish;
  end
endmodule
