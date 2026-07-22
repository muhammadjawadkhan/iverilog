// Smoke: static R#(T) property + typed singleton get() + handle compare.
`timescale 1ns/1ps

module factory_singleton;
  class Base;
    string tag;
    function new(string t = "base");
      tag = t;
    endfunction
  endclass

  class R #(type T = int, parameter string Tname = "x") extends Base;
    typedef R#(T, Tname) this_type;
    static this_type m_inst;
    function new();
      super.new(Tname);
    endfunction
    static function this_type get();
      if (m_inst == null)
        m_inst = new;
      return m_inst;
    endfunction
  endclass

  typedef R#(byte, "pkt") Rb;
  Rb b;
  Rb b2;

  initial begin
    b = Rb::get();
    if (b == null) begin
      $display("FAIL: get null");
      $fatal(1);
    end
    b2 = Rb::get();
    if (b2 == null) begin
      $display("FAIL: get2 null");
      $fatal(1);
    end
    if (b != b2) begin
      $display("FAIL: not singleton");
      $fatal(1);
    end
    if (b.tag != "pkt") begin
      $display("FAIL: tag got '%s'", b.tag);
      $fatal(1);
    end
    $display("PASSED");
    $finish;
  end
endmodule
