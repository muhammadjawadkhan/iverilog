# Driver + analysis (Tier B)

Status: **partial** — `uvm_driver` pulls from a bound `uvm_sequencer`;
`uvm_analysis_port` / `uvm_subscriber` with a single subscriber (virtual `write`).

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class my_driver extends uvm_driver;
  uvm_analysis_port ap;
  virtual task drive_item(uvm_sequence_item item);
    ap.write(item); // virtual write on subscriber
  endtask
endclass

drv.set_sequencer(sqr);
drv.ap.connect(sb);
seq.start(sqr);
drv.run_phase(ph); // get_next_item → drive_item → item_done
```

| API | Notes |
|-----|--------|
| `uvm_driver` | `set_sequencer`, `get_next_item`, `item_done`, virtual `drive_item` / `run_phase` |
| `uvm_subscriber` | virtual `write(uvm_sequence_item)` |
| `uvm_analysis_port` | `connect(subscriber)`, `write` → one subscriber |

## Gaps

- No parameterized `uvm_driver#(REQ)` / analysis `#(T)`
- One analysis subscriber only (no fan-out list)
- No full agent/monitor/env hierarchy

## Example

[`examples/driver`](../examples/driver) — prints `PASSED`.
