# Mini-UVM integrated smoke (roadmap #11)

Status: **partial** — one TB that exercises factory (virtual `create_object`),
`config_db`, phases/objections, and sequences (`start` → virtual `body`).

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What it covers

| Slice | Check |
|-------|--------|
| Factory | type override + `create_object_by_name` via base wrapper handle |
| config_db | string set/get |
| Phases | `run_phase` objections |
| Sequences | `start()` on `uvm_sequence` handle dispatches derived `body()` |
| Virtual methods | used by factory create and sequence `body` |

## Example

[`examples/mini_uvm`](../examples/mini_uvm) — prints `PASSED`.

```bash
make -C examples/mini_uvm run
```
