// Tier B #2 smoke: uvm_config_db#(int)::, uvm_config_db#(string):: (via IS_STR
// trait or explicit #(string,1)), and uvm_config_db_object#(T):: API.
`timescale 1ns/1ps

import ivl_uvm_pkg::*;

class cfg_item extends uvm_object;
  int payload;
  function new(string name = "cfg_item");
    super.new(name);
  endfunction
  virtual function string get_type_name();
    return "cfg_item";
  endfunction
endclass

module config_db_basic;

  int  n;
  int  pass;
  string mode;
  cfg_item obj_in;
  cfg_item obj_out;

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

    // Object-handle resources.
    obj_in = new("obj_in");
    obj_in.payload = 99;
    uvm_config_db_object#(cfg_item)::set("", "env.agent", "cfg", obj_in);
    if (!uvm_config_db_object#(cfg_item)::exists("", "env.agent", "cfg")) begin
      $display("FAIL: exists object");
      pass = 0;
    end
    obj_out = uvm_config_db_object#(cfg_item)::get("", "env.agent", "cfg");
    if (obj_out == null || obj_out.payload !== 99) begin
      $display("FAIL: get object payload mismatch");
      pass = 0;
    end
    else if (obj_out != obj_in) begin
      $display("FAIL: get object handle mismatch");
      pass = 0;
    end

    if (uvm_config_db_object#(cfg_item)::exists("", "env.agent", "missing")) begin
      $display("FAIL: missing object should not exist");
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "config_db_basic failed");
    $finish;
  end
endmodule
