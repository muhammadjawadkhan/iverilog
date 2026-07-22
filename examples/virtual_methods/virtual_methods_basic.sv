// Tier B / compiler: virtual method dispatch + super.method static bind.
`timescale 1ns/1ps

class base;
  int x;
  virtual function string get_type_name();
    return "base";
  endfunction
  virtual function void setx(int v);
    x = v;
  endfunction
  virtual function int getx();
    return x;
  endfunction
  virtual function void build();
    x = 1;
  endfunction
  virtual task bump();
    x = x + 100;
  endtask
endclass

class der extends base;
  virtual function string get_type_name();
    return "der";
  endfunction
  virtual function void setx(int v);
    x = v + 10;
  endfunction
  virtual function int getx();
    return x;
  endfunction
  virtual function void build();
    super.build();
    x = x + 10;
  endfunction
  virtual task bump();
    super.bump();
    x = x + 1;
  endtask
endclass

module virtual_methods_basic;
  base b;
  der  d;
  string s;
  int n;
  int pass;

  initial begin
    pass = 1;
    d = new;
    b = d;

    s = b.get_type_name();
    if (s != "der") begin
      $display("FAIL: get_type_name got '%s'", s);
      pass = 0;
    end

    b.setx(5);
    n = b.getx();
    if (n !== 15) begin
      $display("FAIL: getx got %0d (expect 15)", n);
      pass = 0;
    end

    // super.* is statically bound (no virt recursion).
    b.build();
    b.bump();
    if (d.x !== 112) begin
      $display("FAIL: super chain got %0d (expect 112)", d.x);
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "virtual_methods_basic failed");
    $finish;
  end
endmodule
