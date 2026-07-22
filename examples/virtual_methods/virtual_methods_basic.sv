// Tier B / compiler: virtual method dispatch through class handles.
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

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "virtual_methods_basic failed");
    $finish;
  end
endmodule
