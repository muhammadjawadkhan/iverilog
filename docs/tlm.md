# TLM ports (Tier B)

Status: **partial** — blocking put/get for **int** via `uvm_tlm_fifo` + ports.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
uvm_tlm_fifo f = new;
uvm_blocking_put_port pp = new;
uvm_blocking_get_port gp = new;
pp.connect(f); gp.connect(f);
pp.put(42);
gp.get(x);
```

| API | Notes |
|-----|--------|
| `uvm_tlm_fifo` | int queue; `put` / `get` / `can_get` / `size` |
| `uvm_blocking_put_port` | `connect(fifo)`, `put(int)` |
| `uvm_blocking_get_port` | `connect(fifo)`, `get` / `can_get` |

## Gaps

- No parameterized `uvm_*_port#(T)` (needs `C#(T)` specialization)
- Analysis: single-subscriber `uvm_analysis_port` / `uvm_subscriber` only (see [driver.md](driver.md)); no fan-out / exports / imps hierarchy
- Class-handle / object TLM (no class-handle queues; mailbox not a class property)
- Legacy `ivl_uvm_tlm_pull_*` remains but is separate

## Example

[`examples/tlm`](../examples/tlm) — prints `PASSED`.
