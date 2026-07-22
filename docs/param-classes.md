# Tier A #1 — Parameterized classes

Track: **muhammadjawadkhan/iverilog-uvm** only (`feat/param-classes`). Do not open PRs to `steveicarus/iverilog` for this work.

## Goal

Support SystemVerilog parameterized classes needed for Accellera-shaped UVM (`uvm_*#(T)`, `config_db`, etc.):

```systemverilog
class C #(type T = int, parameter int W = 8);
  // ...
endclass

C#(byte) c;   // explicit specialization
```

## What landed (ANSI parameter ports + defaults)

### Grammar (`parse.y`)

`class_declaration` now pushes the class scope **before** the optional `#(...)` parameter port list (same idea as modules), then applies `extends`:

1. `K_virtual_opt K_class lifetime_opt identifier_name` → start class / typedef (`pform_start_class_declaration` with base type deferred).
2. `module_parameter_port_list_opt` — reuse the existing module ANSI parameter-port grammar so `type T = int`, `parameter int W = 8`, etc. land in the class `LexicalScope`.
3. `class_declaration_extends_opt ';'` → `pform_set_class_extends(...)`.
4. class items / `endclass` as before.

### Pform (`pform_pclass.cc` / `pform.h`)

- **`pform_set_class_extends`** — fills `base_type` / `base_args` on the current class after the parameter port list (replacing the old path that passed extends into `pform_start_class_declaration` before `#(...)` could exist).
- Related: `pform_start_class_declaration`, `pform_end_class_declaration`, property helpers unchanged in role.

With defaults present, a bare instance like `box b;` elaborates using those defaults.

### Explicit specialization `C#(T)` (MVP)

- Parse keeps `#(...)` on `typeref_t` (`box#(byte) b`).
- Elaboration lazily clones the class scope, force-overrides parameter ports (class params are otherwise non-overridable), evaluates, and elaborates methods.
- Ordered and named overrides are accepted; identity is cached by a mangled type name.
- Built-in `mailbox` / `semaphore` still ignore `#()`.

Smoke: [`examples/param_classes/box_special.sv`](../examples/param_classes/box_special.sv) — expects `$bits(b.val)==8`.

```bash
make -C examples/param_classes run
# expect: PASS box_default ... / PASS box_special ... / PASS plain_class ...
```

## TODO

- [ ] `typedef C#(byte) t;` and richer multi-param identity edge cases.
- [ ] Inheritance + parameters interactions as needed by UVM base classes.
- [ ] Broader ivtest coverage beyond the local smoke examples.
- [ ] Accellera-shaped `uvm_*#(T)` registries (needs this path + more).

## Status pointer

See [STATUS.md](STATUS.md) (Parameterized classes row) and [ROADMAP.md](ROADMAP.md) Tier A item 1.
