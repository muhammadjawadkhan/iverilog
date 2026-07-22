# Factory (Tier B #1)

Status: **partial** — name-based register / find / type-override / create, plus Accellera-shaped `uvm_object_registry#(T,Tname)`.

Track: **muhammadjawadkhan/iverilog-uvm** only. Do not open PRs to `steveicarus/iverilog` for this work.

## What works

```systemverilog
class pkt extends uvm_object;
  `ivl_uvm_object_utils(pkt)  // typedef type_id = uvm_object_registry#(pkt,"pkt")
endclass

ok = $cast(w_pkt, pkt::type_id::get());  // singleton auto-registers
obj = uvm_get_factory().create_object_by_name("pkt", "", "p0");
```

| API | Notes |
|-----|--------|
| `uvm_object_wrapper` | `type_name` property; virtual `create_object` / `create_component` |
| `uvm_object_registry#(T,Tname)` | Extends wrapper; `new` / `get()` auto-registers; virtual `create_object` news `T` |
| `TYPE::type_id::get()` | Class-scoped static call; bare `m_inst = new` allocates the enclosing specialization |
| `uvm_factory::register` | Name-keyed type table (fixed size, default 64) |
| `find_by_name` | Lookup registered wrapper |
| `set_type_override_by_name` | Requested → override type name |
| `resolve_type_name` | Follow override chain |
| `create_object_by_name` | Resolve + virtual `w.create_object(name)` |
| `uvm_get_factory()` | Package singleton (`factory` handle) |
| `` `ivl_uvm_object_utils(T) `` | Nested `type_id` typedef + `get_type_name` / `create` |
| `TYPE::type_id` | Class nested typedef scope (`ps_type_identifier` via `class_scope`) |

## Gaps

- `get()` returns `uvm_object_wrapper` (not the specialized registry); `$cast` to `TYPE::type_id` for typed `create`
- No static `type_id::create()` yet (name clash with instance `create`)
- `C#(T)::method()` parse (Accellera `uvm_config_db#(int)::set`) still TODO
- Full Accellera `` `uvm_object_utils `` / field macros still stubbed
- Instance overrides; full coreservice

## Example

[`examples/factory`](../examples/factory) — prints `PASSED`.

```bash
make -C examples/factory run
```
