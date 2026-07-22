# Status

Last updated: 2026-07-22

## Accellera UVM 1.2

**Not supported.** Official Accellera UVM will not compile on stock Icarus or on this fork yet.

## This fork

| Area | Status |
|------|--------|
| Icarus Verilog tree | Fork of `steveicarus/iverilog` (`master` @ merge of SV array ordering work) |
| [`uvm/`](../uvm/) | Seeded from IVL_UVM (VerifWorks) — messaging, CLP, stub phases, legacy poor-man’s mailbox/semaphore classes; **not** Accellera-compatible. Prefer compiler builtins for `mailbox`/`semaphore` (see STATUS row below). |
| [`examples/hello_uvm`](../examples/hello_uvm) | Smoke TB for the seeded library (`Makefile` included) |
| Parameterized classes | **Partial**: ANSI `class C #(type T = int, ...);` with defaults; explicit `C#(byte)` / `typedef C#(byte)` / ordered+named multi-param overrides. See [`param-classes.md`](param-classes.md) / [`examples/param_classes`](../examples/param_classes). |
| Associative arrays | **Partial** on `feat/assoc-array`: string-keyed `int aa[string]` / `int aa[*]` with size/num/exists/delete/foreach/copy. See [`docs/assoc-array.md`](assoc-array.md) and [`examples/assoc_array`](../examples/assoc_array). |
| Virtual interfaces | **Partial** on `feat/virtual-interface`: `virtual interface T` as class property / TF arg; assign interface instance; member R/W; `@(posedge vif.clk)`. See [`docs/virtual-interface.md`](virtual-interface.md) and [`examples/virtual_interface`](../examples/virtual_interface). |
| Clocking blocks | **Partial** on `feat/clocking-blocks`: interface-local `clocking`; `@(bif.cb)`; `cb.sig` R/W with `#0` skew. See [`docs/clocking.md`](clocking.md) and [`examples/clocking`](../examples/clocking). |
| Mailbox / semaphore | **Partial** on `feat/mailbox-semaphore`: compiler builtins; `mailbox #(int)` + blocking/nonblocking put/get/num; `semaphore` get/put/try_get. See [`docs/mailbox-semaphore.md`](mailbox-semaphore.md) and [`examples/mailbox_sem`](../examples/mailbox_sem). |
| Constraints / randomize | **Partial** on `feat/constraints-reject`: unconstrained `rand`/`randc` plus hard relational constraints via rejection sampling (`constraint {}`, `randomize() with`). See [`docs/constraints.md`](constraints.md), [`docs/randomize.md`](randomize.md), [`examples/constraints`](../examples/constraints). |
| `$cast` / `$typename` | **Partial** on `feat/cast-typename`: class-handle `$cast` (dynamic is-a + assign); static `$typename` → `"class <name>"` etc. See [`docs/cast-typename.md`](cast-typename.md) and [`examples/cast_typename`](../examples/cast_typename). |
| Covergroups | **Partial** on `feat/covergroup`: embedded `covergroup`/`coverpoint`/`bins`, `sample()`, `get_inst_coverage()` percentage. See [`docs/covergroup.md`](covergroup.md) and [`examples/covergroup`](../examples/covergroup). |
| DPI-C | **Partial** on `feat/dpi-c`: `import "DPI-C" function` with scalar `int`; load `.so` via `vvp -d`. See [`docs/dpi.md`](dpi.md) and [`examples/dpi`](../examples/dpi). |
| Factory | **Partial** on `feat/factory-slice` (+ virt create): name-based `uvm_factory` register / create / type-override; virtual `create_object`. See [`docs/factory.md`](factory.md) and [`examples/factory`](../examples/factory). |
| config_db | **Partial** on `feat/config-db`: exact-match set/get/exists for `int` and `string`. See [`docs/config-db.md`](config-db.md) and [`examples/config_db`](../examples/config_db). |
| Phases / objections | **Partial** on `feat/phases-objections`: `uvm_objection`, phase objection hooks, component children. See [`docs/phases.md`](phases.md) and [`examples/phases`](../examples/phases). |
| TLM | **Partial** on `feat/tlm-ports`: int `uvm_tlm_fifo` + blocking put/get ports. See [`docs/tlm.md`](tlm.md) and [`examples/tlm`](../examples/tlm). |
| Sequences | **Partial**: `uvm_sequence` / `uvm_sequencer`; `start()` runs virtual `body()`. See [`docs/sequences.md`](sequences.md) and [`examples/sequences`](../examples/sequences). |
| Driver / analysis | **Partial**: `uvm_driver` + `uvm_analysis_port` / `uvm_subscriber` (fixed fan-out). See [`docs/driver.md`](driver.md) and [`examples/driver`](../examples/driver). |
| Agent / monitor / env | **Partial**: `uvm_monitor`, `uvm_agent`, `uvm_env`. See [`docs/agent.md`](agent.md) and [`examples/agent`](../examples/agent). |
| Property method calls | **Partial**: `obj.prop.method()` and `obj.a.b.method()` class-handle chains; nested property reads. See [`docs/property-methods.md`](property-methods.md) and [`examples/property_methods`](../examples/property_methods). |
| Virtual methods | **Partial**: runtime dispatch for class functions/tasks; `super.method` static bind. See [`docs/virtual-methods.md`](virtual-methods.md) and [`examples/virtual_methods`](../examples/virtual_methods). |
| Mini-UVM smoke | **Partial**: factory + config_db + phases + sequences + agent/analysis. See [`docs/mini-uvm.md`](mini-uvm.md) and [`examples/mini_uvm`](../examples/mini_uvm). |

## Remotes

- `origin` → https://github.com/muhammadjawadkhan/iverilog-uvm
- `upstream` → https://github.com/steveicarus/iverilog (fetch only for this track)
