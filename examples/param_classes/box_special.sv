// Smoke: explicit specialization box#(byte) (not defaults).
class box #(type T = int, parameter int W = 8);
  T val;
  bit [W-1:0] data;
  function new(T v);
    val = v;
    data = v;
  endfunction
  function T get();
    return val;
  endfunction
endclass

module top;
  box#(byte) b;
  initial begin
    b = new(8'h5a);
    if (b.get() !== 8'h5a) begin
      $display("FAIL: get=%0h", b.get());
      $finish(1);
    end
    if ($bits(b.val) !== 8) begin
      $display("FAIL: $bits(val)=%0d (expected 8)", $bits(b.val));
      $finish(1);
    end
    if (b.data !== 8'h5a) begin
      $display("FAIL: data=%0h", b.data);
      $finish(1);
    end
    $display("PASS box_special val=%0h bits=%0d data=%0h", b.val, $bits(b.val), b.data);
    $finish;
  end
endmodule
