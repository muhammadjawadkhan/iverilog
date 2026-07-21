// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_comps.svh
// Author(s): Srinivasan Venkataramanan 
//
// Copyright (c) VerifWorks 2016-2020  All Rights Reserved.
// Contact us via: support@verifworks.com
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 3 as published by the Free Software Foundation.
// 
// This program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// 
// ========== Copyright Header End ============================
////////////////////////////////////////////////////////////////////////


class uvm_sequence_item extends uvm_object;
  int sequence_id;

  function new (string name = "uvm_sequence_item");
    super.new (name);
  endfunction : new 

endclass : uvm_sequence_item 

class uvm_report_object extends uvm_object;
  function new (string name = "uvm_report_object");
    super.new (name);
  endfunction : new 

endclass : uvm_report_object 

class uvm_phase extends uvm_object;
  uvm_objection phase_done;

  function new (string name = "uvm_phase");
    super.new (name);
    phase_done = new({name, ".phase_done"});
  endfunction : new 

  function void raise_objection(int count = 1);
    uvm_objection od;
    od = phase_done;
    od.raise_objection(count);
  endfunction

  function void drop_objection(int count = 1);
    uvm_objection od;
    od = phase_done;
    od.drop_objection(count);
  endfunction

  function int get_objection_total();
    uvm_objection od;
    int n;
    od = phase_done;
    n = od.get_objection_total();
    return n;
  endfunction

  task wait_for_objections_drop();
    uvm_objection od;
    od = phase_done;
    od.wait_for_total_count(0);
  endtask
endclass : uvm_phase 

virtual class uvm_component extends uvm_report_object;
  local uvm_component m_parent;
  local uvm_component m_children[`IVL_UVM_MAX_CHILDREN];
  local int m_num_children;

  function new (string name = "uvm_component", uvm_component parent);
    super.new (name);
    m_parent = parent;
    m_num_children = 0;
    if (parent != null)
      parent.m_add_child(this);
  endfunction : new 

  local function void m_add_child(uvm_component child);
    if (m_num_children >= `IVL_UVM_MAX_CHILDREN) begin
      $display("UVM_ERROR @ 0: reporter [COMP] child table full");
      return;
    end
    m_children[m_num_children] = child;
    m_num_children++;
  endfunction

  function uvm_component get_parent();
    return m_parent;
  endfunction

  function int get_num_children();
    return m_num_children;
  endfunction

  function uvm_component get_child(int idx);
    if (idx < 0 || idx >= m_num_children)
      return null;
    return m_children[idx];
  endfunction

  virtual function void build_phase(uvm_phase phase);
    `g2u_display ("build_phase", UVM_HIGH)
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    `g2u_display ("connect_phase", UVM_HIGH)
  endfunction : connect_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    `g2u_display ("end_of_elaboration_phase", UVM_HIGH)
  endfunction : end_of_elaboration_phase
  virtual function void start_of_simulation_phase(uvm_phase phase);
    `g2u_display ("start_of_simulation_phase", UVM_HIGH)
  endfunction : start_of_simulation_phase

  virtual task run_phase (uvm_phase phase);
    `g2u_display ("run_phase", UVM_HIGH)
    this.print (uvm_default_printer);
  endtask : run_phase 

  virtual function void extract_phase(uvm_phase phase);
  endfunction : extract_phase
  virtual function void check_phase(uvm_phase phase);
  endfunction : check_phase
  virtual function void report_phase(uvm_phase phase);
  endfunction : report_phase
  virtual function void final_phase(uvm_phase phase);
  endfunction : final_phase

  // Top-down function phases on this subtree (exact static types when
  // called on concrete roots). Child overrides need virtual dispatch.
  function void ivl_uvm_apply_func_phase(string which, uvm_phase phase);
    int i;
    uvm_component ch;
    if (which == "build")
      build_phase(phase);
    else if (which == "connect")
      connect_phase(phase);
    else if (which == "end_of_elaboration")
      end_of_elaboration_phase(phase);
    else if (which == "start_of_simulation")
      start_of_simulation_phase(phase);
    else if (which == "extract")
      extract_phase(phase);
    else if (which == "check")
      check_phase(phase);
    else if (which == "report")
      report_phase(phase);
    else if (which == "final")
      final_phase(phase);

    for (i = 0; i < m_num_children; i++) begin
      ch = m_children[i];
      ch.ivl_uvm_apply_func_phase(which, phase);
    end
  endfunction

  virtual task ivl_uvm_run_all_phases ();
    uvm_phase u_ph_0;
    int i;
    uvm_component ch;

    u_ph_0 = new("common");
    ivl_uvm_apply_func_phase("build", u_ph_0);
    ivl_uvm_apply_func_phase("connect", u_ph_0);
    ivl_uvm_apply_func_phase("end_of_elaboration", u_ph_0);
    ivl_uvm_apply_func_phase("start_of_simulation", u_ph_0);

    // run_phase: this component, then children (fork-free sequential).
    run_phase(u_ph_0);
    for (i = 0; i < m_num_children; i++) begin
      ch = m_children[i];
      ch.run_phase(u_ph_0);
    end
    u_ph_0.wait_for_objections_drop();

    ivl_uvm_apply_func_phase("extract", u_ph_0);
    ivl_uvm_apply_func_phase("check", u_ph_0);
    ivl_uvm_apply_func_phase("report", u_ph_0);
    ivl_uvm_apply_func_phase("final", u_ph_0);
  endtask : ivl_uvm_run_all_phases 

endclass : uvm_component

virtual class uvm_test extends uvm_component;
  function new (string name = "uvm_test", uvm_component parent = null);
    super.new (name, parent);
    `g2u_display ("%m");
  endfunction : new 
endclass : uvm_test 

// Default concrete test so run_test() can instantiate when no +define+UVM_TESTNAME=... is given.
// (Icarus elaboration rejects new() on a virtual class type.)
class ivl_uvm_default_test extends uvm_test;
  function new (string name = "ivl_uvm_default_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass : ivl_uvm_default_test
