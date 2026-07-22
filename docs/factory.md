# Factory (Tier B #1)

Status: **partial** — name-based register / find / type-override / create, plus Accellera-shaped `uvm_object_registry#(T,Tname)`.

Track: **muhammadjawadkhan/iverilog-uvm** only. Do not open PRs to `steveicarus/iverilog` for this work.

## What works

```systemverilog
class pkt extends uvm_object;
  `ivl_uvm_object_utils(pkt)  // typedef type_id = uvm_object_registry#(pkt,"pkt")
endclass

w_pkt = pkt::type_id::get();              // typed this_type singleton, auto-registers
p = pkt::type_id::create("p0");           // static create via get()+create_object
obj = uvm_get_factory().create_object_by_name("pkt", "", "p0");
```

| API | Notes |
|-----|--------|
| `uvm_object_wrapper` | `type_name` property; virtual `create_object` / `create_component` |
| `uvm_object_registry#(T,Tname)` | Extends wrapper; nested `this_type`; `new` / `get()` auto-registers |
| `TYPE::type_id::get()` | Returns `this_type` (no `$cast`); bare `m_inst = new` allocates specialization |
| `TYPE::type_id::create(name)` | Static; typed `T` return via `get()` + virtual `create_object` |
| `static R#(T[,Tname]) prop` | Class property with explicit `#()` specialization |
| Class-handle `==` / `!=` | Identity compare via `%cmp/obj` |
| `uvm_factory::register` | Name-keyed type table (fixed size, default 64) |
| `find_by_name` | Lookup registered wrapper |
| `set_type_override_by_name` | Requested → override type name |
| `resolve_type_name` | Follow override chain |
| `create_object_by_name` | Resolve + virtual `w.create_object(name)` |
| `uvm_get_factory()` | Package singleton (`factory` handle) |
| `` `ivl_uvm_object_utils(T) `` | Nested `type_id` typedef + `get_type_name` / `create` |
| `TYPE::type_id` | Class nested typedef scope (`ps_type_identifier` via `class_scope`) |

## Gaps

- `static function R#(T) get()` return type still does not parse (use `typedef … this_type`)
- Full Accellera `` `uvm_object_utils `` / field macros still stubbed
- Instance overrides; full coreservice

## Examples

[`examples/factory`](../examples/factory) — `factory_basic` prints `PASSED`; `factory_singleton` exercises `static R#(T)` + handle compare.

```bash
make -C examples/factory run
make -C examples/factory run-singleton
```
