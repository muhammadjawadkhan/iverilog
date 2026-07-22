// Tier B smoke: blocking put/get ports wired to uvm_tlm_fifo (int).
`timescale 1ns/1ps

module tlm_basic;
  import ivl_uvm_pkg::*;

  uvm_tlm_fifo           fifo;
  uvm_blocking_put_port  pp;
  uvm_blocking_get_port  gp;
  int x;
  int y;
  int pass;

  initial begin
    pass = 1;
    fifo = new("fifo");
    pp = new("pp");
    gp = new("gp");
    pp.connect(fifo);
    gp.connect(fifo);

    pp.put(42);
    gp.get(x);
    if (x !== 42) begin
      $display("FAIL: get got %0d", x);
      pass = 0;
    end

    pp.put(7);
    pp.put(8);
    if (!gp.can_get()) begin
      $display("FAIL: can_get after put");
      pass = 0;
    end
    gp.get(y);
    if (y !== 7) begin
      $display("FAIL: first of two got %0d", y);
      pass = 0;
    end
    gp.get(y);
    if (y !== 8) begin
      $display("FAIL: second get got %0d", y);
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "tlm_basic failed");
    $finish;
  end
endmodule
