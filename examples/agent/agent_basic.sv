// Tier B smoke: uvm_agent + uvm_monitor + nested property chains.
`timescale 1ns/1ps

module agent_basic;
  import ivl_uvm_pkg::*;

  class my_item extends uvm_sequence_item;
    function new(string name = "my_item");
      super.new(name);
    endfunction
  endclass

  class my_seq extends uvm_sequence;
    function new(string name = "my_seq");
      super.new(name);
    endfunction
    virtual task body();
      my_item it;
      it = new("it0");
      it.data = 42;
      start_item(it);
      finish_item(it);
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
      my_item mi;
      bit ok;
      ok = $cast(mi, t);
      if (ok) begin
        last_data = mi.data;
        seen = seen + 1;
      end
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
    function new(string name = "my_env", uvm_component parent = null);
      super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
      agent = new("agent", this);
      sb = new("sb", this);
      agent.build_phase(phase);
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      agent.connect_phase(phase);
      agent.monitor.ap.connect(sb);
    endfunction
  endclass

  my_env     env;
  my_seq     seq;
  uvm_phase  ph;
  scoreboard sb;
  int        pass;

  initial begin
    pass = 1;
    env = new("env", null);
    seq = new("seq");
    ph = new("build");
    env.build_phase(ph);
    ph = new("connect");
    env.connect_phase(ph);
    sb = env.sb;

    seq.start(env.agent.sequencer);
    ph = new("run");
    env.agent.driver.run_phase(ph);
    ph.wait_for_objections_drop();

    if (sb.seen !== 1 || sb.last_data !== 42) begin
      $display("FAIL: seen=%0d data=%0d", sb.seen, sb.last_data);
      pass = 0;
    end

    if (pass)
      $display("PASSED");
    else
      $fatal(1, "agent_basic failed");
    $finish;
  end
endmodule
