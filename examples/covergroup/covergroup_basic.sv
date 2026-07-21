class cov;
  bit [1:0] v;
  covergroup cg;
    coverpoint v {
      bins lo = {0,1};
      bins hi = {2,3};
    }
  endgroup
  function new();
    cg = new;
  endfunction
endclass

module top;
  cov c = new;
  real r;
  initial begin
    c.v = 0; c.cg.sample();
    c.v = 3; c.cg.sample();
    r = c.cg.get_inst_coverage();
    if (r <= 0.0) $fatal(1, "coverage should be > 0, got %f", r);
    $display("coverage=%0f", r);
    $display("PASSED");
  end
endmodule
