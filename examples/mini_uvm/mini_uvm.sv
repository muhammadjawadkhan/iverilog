// Tier B #11 smoke: factory + config_db + phases + sequences + agent/analysis.
`timescale 1ns/1ps

module mini_uvm;
  import ivl_uvm_pkg::*;

  class pkt extends uvm_object;
    int kind;
    function new(string name = "pkt");
      super.new(name);
      kind = 1;
    endfunction
    `ivl_uvm_object_utils(pkt)
  endclass

  class pkt_ext extends pkt;
    function new(string name = "pkt_ext");
      super.new(name);
      kind = 2;
    endfunction
    `ivl_uvm_object_utils(pkt_ext)
  endclass

  class pkt_wrapper extends uvm_object_wrapper;
    function new();
      super.new("pkt");
    endfunction
    virtual function uvm_object create_object(string name = "");
      pkt o;
      o = new(name);
      return o;
    endfunction
  endclass

  class pkt_ext_wrapper extends uvm_object_wrapper;
    function new();
      super.new("pkt_ext");
    endfunction
    virtual function uvm_object create_object(string name = "");
      pkt_ext o;
      o = new(name);
      return o;
    endfunction
  endclass

  class pkt_item extends uvm_sequence_item;
    function new(string name = "pkt_item");
      super.new(name);
    endfunction
  endclass

  class pkt_seq extends uvm_sequence;
    function new(string name = "pkt_seq");
      super.new(name);
    endfunction
    virtual task body();
      pkt_item it;
      uvm_factory fac;
      uvm_object obj;
      pkt p;
      bit ok;
      fac = uvm_get_factory();
      obj = fac.create_object_by_name("pkt", "", "seq_pkt");
      ok = $cast(p, obj);
      it = new("it0");
      if (ok)
        it.data = p.kind;
      else
        it.data = -1;
      start_item(it);
      finish_item(it);
    endtask
  endclass

  class mini_test extends uvm_test;
    int ran;
    function new(string name = "mini_test", uvm_component parent = null);
      super.new(name, parent);
      ran = 0;
    endfunction
    task run_phase(uvm_phase phase);
      phase.raise_objection(1);
      #1;
      ran = 1;
      phase.drop_objection(1);
    endtask
  endclass

  class scoreboard extends uvm_subscriber;
    int last_data;
    int seen;
    function new(string name = "scoreboard", uvm_component parent = null);
      super.new(name, parent);
      last_data = 0;
      seen = 0;
    endfunction
    virtual function void write(uvm_sequence_item t);
      pkt_item mi;
      bit ok;
      ok = $cast(mi, t);
      if (ok) begin
        last_data = mi.data;
        seen = seen + 1;
      end
    endfunction
  endclass

  class coverage extends uvm_subscriber;
    int hits;
    function new(string name = "coverage", uvm_component parent = null);
      super.new(name, parent);
      hits = 0;
    endfunction
    virtual function void write(uvm_sequence_item t);
      hits = hits + 1;
    endfunction
  endclass

  class my_driver extends uvm_driver;
    uvm_monitor mon;
    function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    virtual task drive_item(uvm_sequence_item item);
      if (mon != null)
        mon.sample_and_write(item);
    endtask
  endclass

  class my_agent extends uvm_agent;
    function new(string name = "my_agent", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
      my_driver drv;
      super.build_phase(phase);
      drv = new("driver", this);
      driver = drv;
      drv.mon = monitor;
    endfunction
  endclass

  class my_env extends uvm_env;
    my_agent agent;
    scoreboard sb;
    coverage cov;
    function new(string name = "my_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
      agent = new("agent", this);
      sb = new("sb", this);
      cov = new("cov", this);
      agent.build_phase(phase);
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      agent.connect_phase(phase);
      agent.monitor.ap.connect(sb);
      agent.monitor.ap.connect(cov);
    endfunction
  endclass

  pkt_wrapper     w_pkt;
  pkt_ext_wrapper w_ext;
  uvm_factory     fac;
  ivl_uvm_config_db_box   cdb;
  uvm_sequencer   sqr;
  uvm_sequence    seq_h;
  pkt_seq         seq;
  mini_test       tst;
  my_env          env;
  uvm_phase       ph;
  uvm_sequence_item got;
  pkt_item        mi;
  uvm_object      obj;
  pkt_ext         pe;
  scoreboard      sb;
  coverage        cov;
  bit             ok;
  int             pass;
  string          mode;

  initial begin
    pass = 1;

    // --- factory + virt create_object ---
    w_pkt = new;
    w_ext = new;
    fac = uvm_get_factory();
    fac.register(w_pkt);
    fac.register(w_ext);
    fac.set_type_override_by_name("pkt", "pkt_ext");
    obj = fac.create_object_by_name("pkt", "", "p0");
    ok = $cast(pe, obj);
    if (!ok || pe.kind !== 2) begin
      $display("FAIL: factory virt create");
      pass = 0;
    end

    // --- config_db ---
    cdb = uvm_get_config_db();
    cdb.set_string("uvm_test_top", "", "mode", "mini");
    mode = cdb.get_string("uvm_test_top", "", "mode");
    if (mode != "mini") begin
      $display("FAIL: config_db");
      pass = 0;
    end

    // --- phases / objections ---
    tst = new("tst", null);
    ph = new("run");
    tst.run_phase(ph);
    ph.wait_for_objections_drop();
    if (tst.ran !== 1) begin
      $display("FAIL: phases");
      pass = 0;
    end

    // --- sequences: start() on base handle → virtual body ---
    sqr = new("sqr", null);
    seq = new("seq");
    seq_h = seq;
    seq_h.start(sqr);
    sqr.get_next_item(got);
    ok = $cast(mi, got);
    if (!ok || mi.data !== 2) begin
      $display("FAIL: sequence data ok=%0b data=%0d", ok, mi.data);
      pass = 0;
    end
    sqr.item_done();

    // --- agent + analysis fan-out (nested props) ---
    env = new("env", null);
    seq = new("seq");
    ph = new("build");
    env.build_phase(ph);
    ph = new("connect");
    env.connect_phase(ph);
    sb = env.sb;
    cov = env.cov;
    if (env.agent.monitor.ap.size() !== 2) begin
      $display("FAIL: analysis fan-out size=%0d", env.agent.monitor.ap.size());
      pass = 0;
    end
    seq.start(env.agent.sequencer);
    ph = new("run");
    env.agent.driver.run_phase(ph);
    ph.wait_for_objections_drop();
    if (sb.seen !== 1 || sb.last_data !== 2) begin
      $display("FAIL: agent sb seen=%0d data=%0d", sb.seen, sb.last_data);
      pass = 0;
    end
    if (cov.hits !== 1) begin
      $display("FAIL: agent cov hits=%0d", cov.hits);
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "mini_uvm failed");
    $finish;
  end
endmodule
