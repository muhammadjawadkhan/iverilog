// Smoke: ordered + named multi-parameter overrides.
class box #(type T = int, parameter int W = 8);
  T val;
  bit [W-1:0] data;
  function new(T v);
    val = v;
    data = v;
  endfunction
endclass

module top;
  box#(byte, 16) b_ord;
  box#(.T(byte), .W(4)) b_named;
  initial begin
    b_ord = new(8'h5a);
    b_named = new(4'h3);
    if ($bits(b_ord.val) !== 8 || $bits(b_ord.data) !== 16) begin
      $display("FAIL ordered val=%0d data=%0d", $bits(b_ord.val), $bits(b_ord.data));
      $finish(1);
    end
    if ($bits(b_named.val) !== 8 || $bits(b_named.data) !== 4) begin
      $display("FAIL named val=%0d data=%0d", $bits(b_named.val), $bits(b_named.data));
      $finish(1);
    end
    $display("PASS box_multiparm ord=%0d/%0d named=%0d/%0d",
             $bits(b_ord.val), $bits(b_ord.data),
             $bits(b_named.val), $bits(b_named.data));
    $finish;
  end
endmodule
