// Smoke: derived class extends an explicit specialization.
class box #(type T = int);
  T val;
  function new(T v);
    val = v;
  endfunction
endclass

class byte_box extends box#(byte);
  function new(byte v);
    super.new(v);
  endfunction
  function byte get();
    return val;
  endfunction
endclass

module top;
  byte_box b;
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
    $display("PASS box_extends val=%0h bits=%0d", b.val, $bits(b.val));
    $finish;
  end
endmodule
