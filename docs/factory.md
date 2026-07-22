# Factory (Tier B #1)

Status: **partial** — name-based register / find / type-override / create on the seeded IVL_UVM layer. Creation uses virtual `create_object`.

Track: **muhammadjawadkhan/iverilog-uvm** only. Do not open PRs to `steveicarus/iverilog` for this work.

## What works

```systemverilog
class pkt_wrapper extends uvm_object_wrapper;
  function new(); super.new("pkt"); endfunction
  virtual function uvm_object create_object(string name="");
    pkt o = new(name); return o;
  endfunction
endclass

f = uvm_get_factory();
f.register(w_pkt);
f.set_type_override_by_name("pkt", "pkt_ext");
obj = f.create_object_by_name("pkt", "", "p0"); // virtual create_object
```

| API | Notes |
|-----|--------|
| `uvm_object_wrapper` | `type_name` property; virtual `create_object` / `create_component` |
| `uvm_factory::register` | Name-keyed type table (fixed size, default 64) |
| `find_by_name` | Lookup registered wrapper |
| `set_type_override_by_name` | Requested → override type name |
| `resolve_type_name` | Follow override chain |
| `create_object_by_name` | Resolve + virtual `w.create_object(name)` |
| `uvm_get_factory()` | Package singleton (`factory` handle) |
| `` `ivl_uvm_object_utils(T) `` | `get_type_name` + `create` without `uvm_object_registry#(T)` |

## Gaps

- Derived-class methods cannot call inherited methods by unqualified name
- Class properties cannot hold string fixed-arrays or associative arrays → factory tables are package-level
- `uvm_object_registry#(T)` / `` `uvm_object_utils `` (needs `C#(T)` specialization)
- Instance overrides; full coreservice

## Example

[`examples/factory`](../examples/factory) — prints `PASSED`.

```bash
make -C examples/factory run
```
