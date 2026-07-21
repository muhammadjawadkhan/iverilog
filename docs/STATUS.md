# Status

Last updated: 2026-07-21

## Accellera UVM 1.2

**Not supported.** Official Accellera UVM will not compile on stock Icarus or on this fork yet.

## This fork

| Area | Status |
|------|--------|
| Icarus Verilog tree | Fork of `steveicarus/iverilog` (`master` @ merge of SV array ordering work) |
| [`uvm/`](../uvm/) | Seeded from IVL_UVM (VerifWorks) — messaging, CLP, stub phases, legacy poor-man’s mailbox/semaphore classes; **not** Accellera-compatible. Prefer compiler builtins for `mailbox`/`semaphore` (see STATUS row below). |
| [`examples/hello_uvm`](../examples/hello_uvm) | Smoke TB for the seeded library (`Makefile` included) |
| Parameterized classes | **Partial** on `feat/param-classes` (merged): ANSI `class C #(type T = int, parameter int W = 8);` parses into the class scope and elaborates with **defaults**. Explicit specializations `C#(byte)` / overrides not done yet. See [`examples/param_classes`](../examples/param_classes). |
| Associative arrays | **Partial** on `feat/assoc-array`: string-keyed `int aa[string]` / `int aa[*]` with size/num/exists/delete/foreach/copy. See [`docs/assoc-array.md`](assoc-array.md) and [`examples/assoc_array`](../examples/assoc_array). |
| Virtual interfaces | **Partial** on `feat/virtual-interface`: `virtual interface T` as class property / TF arg; assign interface instance; member R/W; `@(posedge vif.clk)`. See [`docs/virtual-interface.md`](virtual-interface.md) and [`examples/virtual_interface`](../examples/virtual_interface). |
| Clocking blocks | **Partial** on `feat/clocking-blocks`: interface-local `clocking`; `@(bif.cb)`; `cb.sig` R/W with `#0` skew. See [`docs/clocking.md`](clocking.md) and [`examples/clocking`](../examples/clocking). |
| Mailbox / semaphore | **Partial** on `feat/mailbox-semaphore`: compiler builtins; `mailbox #(int)` + blocking/nonblocking put/get/num; `semaphore` get/put/try_get. See [`docs/mailbox-semaphore.md`](mailbox-semaphore.md) and [`examples/mailbox_sem`](../examples/mailbox_sem). |
| Constraints / randomize | **Partial** on `feat/constraints-reject`: unconstrained `rand`/`randc` plus hard relational constraints via rejection sampling (`constraint {}`, `randomize() with`). See [`docs/constraints.md`](constraints.md), [`docs/randomize.md`](randomize.md), [`examples/constraints`](../examples/constraints). |
| `$cast` / `$typename` | **Partial** on `feat/cast-typename`: class-handle `$cast` (dynamic is-a + assign); static `$typename` → `"class <name>"` etc. See [`docs/cast-typename.md`](cast-typename.md) and [`examples/cast_typename`](../examples/cast_typename). |
| Covergroups | **Partial** on `feat/covergroup`: embedded `covergroup`/`coverpoint`/`bins`, `sample()`, `get_inst_coverage()` percentage. See [`docs/covergroup.md`](covergroup.md) and [`examples/covergroup`](../examples/covergroup). |
| DPI-C | **Partial** on `feat/dpi-c`: `import "DPI-C" function` with scalar `int`; load `.so` via `vvp -d`. See [`docs/dpi.md`](dpi.md) and [`examples/dpi`](../examples/dpi). |
| Factory | **Partial** on `feat/factory-slice`: name-based `uvm_factory` register / create / type-override; `uvm_object_wrapper` proxies; no `uvm_object_registry#(T)` yet. See [`docs/factory.md`](factory.md) and [`examples/factory`](../examples/factory). |

## Remotes

- `origin` → https://github.com/muhammadjawadkhan/iverilog-uvm
- `upstream` → https://github.com/steveicarus/iverilog (fetch only for this track)
