# Sequences (Tier B)

Status: **partial** — `uvm_sequence_item`, `uvm_sequencer`, `uvm_sequence` with `start` / virtual `body` / `finish_item`.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class my_seq extends uvm_sequence;
  virtual task body();
    my_item it = new;
    it.data = 99;
    start_item(it);
    finish_item(it); // pushes to sequencer mailbox
  endtask
endclass

uvm_sequence seq_h = seq;
seq_h.start(sqr); // binds sequencer and runs virtual body()
sqr.get_next_item(got);
sqr.item_done();
```

| API | Notes |
|-----|--------|
| `uvm_sequence_item` | `sequence_id`, `data` |
| `uvm_sequencer` | `put_item` / `get_next_item` / `item_done` |
| `uvm_sequence` | `start(sqr)` binds + calls virtual `body()` |

Channel is a **package-level** `mailbox #(uvm_sequence_item)` (one shared channel).

## Gaps

- No `uvm_sequence#(REQ,RSP)` / parameterized sequencer
- No arbitration, grab/lock, response path
- Mailbox arrays crash → not multi-sequencer isolated
- No `uvm_driver` base (example pulls on sequencer directly)

## Example

[`examples/sequences`](../examples/sequences) — prints `PASSED`.
