// Tier B #2 smoke: uvm_config_db#(int)::set/get/exists + string helpers.
`timescale 1ns/1ps

module config_db_basic;
  import ivl_uvm_pkg::*;

  ivl_uvm_config_db_box cdb;
  int  n;
  int  pass;
  string mode;

  initial begin
    pass = 1;

    // Accellera-shaped: C#(T)::method() as statement + expression.
    uvm_config_db#(int)::set("", "env.agent", "max_count", 10);
    if (!uvm_config_db#(int)::exists("", "env.agent", "max_count")) begin
      $display("FAIL: exists");
      pass = 0;
    end
    n = uvm_config_db#(int)::get("", "env.agent", "max_count");
    if (n !== 10) begin
      $display("FAIL: get got %0d", n);
      pass = 0;
    end

    if (uvm_config_db#(int)::exists("", "env.agent", "missing")) begin
      $display("FAIL: missing should not exist");
      pass = 0;
    end

    // String still via instance helpers (no #(string) store yet).
    cdb = uvm_get_config_db();
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

    uvm_config_db#(int)::set("", "env.agent", "max_count", 42);
    n = uvm_config_db#(int)::get("", "env.agent", "max_count");
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
