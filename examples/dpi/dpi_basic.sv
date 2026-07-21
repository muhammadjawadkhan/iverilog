// Minimal DPI-C import smoke test (Tier A #9).
import "DPI-C" function int dpi_add(int a, int b);

module top;
  initial begin
    if (dpi_add(2, 3) !== 5) $fatal(1, "FAILED");
    $display("PASSED");
  end
endmodule
