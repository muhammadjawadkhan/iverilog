# Phases / objections (Tier B)

Status: **partial** — `uvm_objection` raise/drop/wait, `uvm_phase` objection hooks, component parent/child table.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
uvm_objection o = new("obj");
o.raise_objection(2);
o.drop_objection(2);
o.wait_for_total_count(0);

phase.raise_objection(1);
// ... work ...
phase.drop_objection(1);
phase.wait_for_objections_drop();

leaf = new("leaf", this); // registers child
n = get_num_children();
```

## Gaps

- Full Accellera phase schedule / domain / jump
- Objection hierarchical propagation to parents
- Child `run_phase` overrides via `uvm_component` handles (needs virtual method dispatch)
- Event-based wait (uses `#1` poll)

## Example

[`examples/phases`](../examples/phases) — prints `PASSED`.
