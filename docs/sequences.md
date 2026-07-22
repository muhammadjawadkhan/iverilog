# Sequences (Tier B)

Status: **partial** — `uvm_sequence_item`, `uvm_sequencer`, `uvm_sequence` with `start` / `body` / `finish_item`.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class my_seq extends uvm_sequence;
  task body();
    my_item it = new;
    it.data = 99;
    start_item(it);
    finish_item(it); // pushes to sequencer mailbox
  endtask
endclass

seq.start(sqr); // binds sequencer only (no virt body call)
seq.body();     // call on concrete derived handle
sqr.get_next_item(got);
sqr.item_done();
```

| API | Notes |
|-----|--------|
| `uvm_sequence_item` | `sequence_id`, `data` |
| `uvm_sequencer` | `put_item` / `get_next_item` / `item_done` |
| `uvm_sequence` | `start(sqr)` binds only; call `body` on concrete type |

Channel is a **package-level** `mailbox #(uvm_sequence_item)` (one shared channel).

## Gaps

- No `uvm_sequence#(REQ,RSP)` / parameterized sequencer
- No arbitration, grab/lock, response path
- Mailbox arrays crash → not multi-sequencer isolated
- **No virtual `body`** — `start()` does not call `body()`; invoke on a derived static type
- No `uvm_driver` base (example pulls on sequencer directly)

## Example

[`examples/sequences`](../examples/sequences) — prints `PASSED`.
