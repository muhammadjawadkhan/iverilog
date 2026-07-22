# Mini-UVM integrated smoke (roadmap #11)

Status: **partial** — one TB that exercises factory (virtual `create_object`),
`config_db`, phases/objections, sequences (`start` → virtual `body`), plus
agent/monitor with analysis fan-out.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What it covers

| Slice | Check |
|-------|--------|
| Factory | type override + `create_object_by_name` via base wrapper handle |
| config_db | string set/get |
| Phases | `run_phase` objections |
| Sequences | `start()` on `uvm_sequence` handle dispatches derived `body()` |
| Agent / analysis | `my_env` → agent → monitor AP → two subscribers |
| Nested props | `env.agent.sequencer`, `agent.monitor.ap.connect` |
| Virtual methods | factory create, sequence `body`, driver `drive_item`, subscriber `write` |

## Example

[`examples/mini_uvm`](../examples/mini_uvm) — prints `PASSED`.

```bash
make -C examples/mini_uvm run
```
