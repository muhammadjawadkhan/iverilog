# Feature roadmap (one-by-one)

Each item should be a dedicated `feat/<name>` branch, with tests/examples and a STATUS.md update. Merge only into this fork’s default branch (`master`).

## Tier A — Compiler SV foundations (block Accellera UVM)

1. **Parameterized classes** — `class C #(type T = int);` / `C#(byte)` — needed for `uvm_*#(T)`, `config_db` — **partial** (defaults; see STATUS)
2. **Associative arrays** — `int aa[string];` — **in progress / partial** (string keys only; see [assoc-array.md](assoc-array.md))
3. **Virtual interfaces** + eventing on `vif.clk` — **partial** (see [virtual-interface.md](virtual-interface.md))
4. **Clocking blocks** — enough for `@(vif.cb)` — **partial** (interface-local `@(bif.cb)`; see [clocking.md](clocking.md))
5. **`mailbox` / `semaphore` builtins** (or solid class equivalents with blocking put/get) — **partial** (int mailbox + semaphore; see [mailbox-semaphore.md](mailbox-semaphore.md))
6. **Constraints + `randomize()` / `randomize() with`** — **partial** (hard relational constraints via rejection sampling; see [constraints.md](constraints.md) / [randomize.md](randomize.md)); soft/dist/solver still missing
7. **`$cast` / `$typename` hardening** for factory patterns — **partial** (class-handle `$cast` + static `$typename`; see [cast-typename.md](cast-typename.md))
8. **Covergroups** — functional coverage — **partial** (embedded coverpoint/bins + `sample`/`get_inst_coverage`; see [covergroup.md](covergroup.md))
9. **DPI-C** — optional but common in real flows — **partial** (`import "DPI-C" function` + scalar int; see [dpi.md](dpi.md))

## Tier B — Library / methodology (on top of Tier A)

10. Grow [`uvm/`](../uvm/) toward Accellera-shaped APIs: reporting, phases/objections, factory, `config_db`, TLM, sequences
    - **Factory** — **partial** (name-based register/create/override; see [factory.md](factory.md))
11. Smoke: trimmed “hello UVM”, then larger Accellera UVM 1.2 slices as features land

## Already usable baseline (do not re-do first)

Classes, packages, strings, queues/dynamic arrays, locators/reductions/ordering, chained calls — extend only when a UVM example needs a gap.

## Out of scope

- Claiming “UVM 1.2 supported” until Accellera’s library compiles and runs
- Opening PRs to `steveicarus/iverilog` for this track (see [WORKFLOW.md](WORKFLOW.md))
