// Tier B #2 smoke: uvm_config_db#(int):: and uvm_config_db#(string,1):: API.
`timescale 1ns/1ps

module config_db_basic;
  import ivl_uvm_pkg::*;

  int  n;
  int  pass;
  string mode;

  initial begin
    pass = 1;

    uvm_config_db#(int)::set("", "env.agent", "max_count", 10);
    if (!uvm_config_db#(int)::exists("", "env.agent", "max_count")) begin
      $display("FAIL: exists int");
      pass = 0;
    end
    n = uvm_config_db#(int)::get("", "env.agent", "max_count");
    if (n !== 10) begin
      $display("FAIL: get int got %0d", n);
      pass = 0;
    end

    if (uvm_config_db#(int)::exists("", "env.agent", "missing")) begin
      $display("FAIL: missing int should not exist");
      pass = 0;
    end

    uvm_config_db#(string, 1)::set("uvm_test_top", "", "mode", "fast");
    if (!uvm_config_db#(string, 1)::exists("uvm_test_top", "", "mode")) begin
      $display("FAIL: exists string");
      pass = 0;
    end
    mode = uvm_config_db#(string, 1)::get("uvm_test_top", "", "mode");
    if (mode != "fast") begin
      $display("FAIL: get string got '%s'", mode);
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
