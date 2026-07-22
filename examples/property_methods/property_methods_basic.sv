// Compiler: class-handle property method calls (obj.prop.method).
`timescale 1ns/1ps

class inner;
  int x;
  function void setx(int v);
    x = v;
  endfunction
  function int getx();
    return x;
  endfunction
endclass

class outer;
  inner ap;
  function new();
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
      $display("FAIL: got %0d", n);
      pass = 0;
    end
    if (pass)
      $display("PASSED");
    else
      $fatal(1, "property_methods_basic failed");
    $finish;
  end
endmodule
