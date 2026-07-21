// Tier B #2 smoke: config_db set/get/exists for int and string.
`timescale 1ns/1ps

module config_db_basic;
  import ivl_uvm_pkg::*;

  uvm_config_db cdb;
  int  n;
  int  pass;
  string mode;

  initial begin
    pass = 1;
    cdb = uvm_get_config_db();

    cdb.set_int("", "env.agent", "max_count", 10);
    if (!cdb.exists_int("", "env.agent", "max_count")) begin
      $display("FAIL: exists_int");
      pass = 0;
    end
    n = cdb.get_int("", "env.agent", "max_count");
    if (n !== 10) begin
      $display("FAIL: get_int got %0d", n);
      pass = 0;
    end

    // Missing key
    if (cdb.exists_int("", "env.agent", "missing")) begin
      $display("FAIL: missing should not exist");
      pass = 0;
    end

    cdb.set_string("uvm_test_top", "", "mode", "fast");
    if (!cdb.exists_string("uvm_test_top", "", "mode")) begin
      $display("FAIL: exists_string");
      pass = 0;
    end
    mode = cdb.get_string("uvm_test_top", "", "mode");
    if (mode != "fast") begin
      $display("FAIL: get_string got '%s'", mode);
      pass = 0;
    end

    // Overwrite
    cdb.set_int("", "env.agent", "max_count", 42);
    n = cdb.get_int("", "env.agent", "max_count");
    if (n !== 42) begin
      $display("FAIL: overwrite got %0d", n);
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "config_db_basic failed");
    $finish;
  end
endmodule
