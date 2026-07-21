// Hard constraints + randomize() with — rejection-sampling smoke test.
class pkt;
  rand bit [3:0] a;
  rand bit [3:0] b;
  constraint c_ab { a < 4; b == a; }
endclass

module top;
  pkt p;
  bit ok;
  initial begin
    p = new;
    ok = p.randomize();
    if (!ok) $fatal(1, "randomize failed");
    if (!(p.a < 4 && p.b == p.a)) $fatal(1, "constraint violated a=%0d b=%0d", p.a, p.b);
    ok = p.randomize() with { a == 2; };
    if (!ok || p.a !== 2 || p.b !== 2) $fatal(1, "with failed a=%0d b=%0d", p.a, p.b);
    $display("PASSED a=%0d b=%0d", p.a, p.b);
  end
endmodule
