# config_db (Tier B #2)

Status: **partial** — exact-match `set`/`get`/`exists` for `int` via Accellera-shaped `uvm_config_db#(int)::`, plus string helpers on `ivl_uvm_config_db_box`.

Track: **muhammadjawadkhan/iverilog-uvm** only. Do not open PRs to `steveicarus/iverilog` for this work.

## What works

```systemverilog
uvm_config_db#(int)::set("", "env.agent", "max_count", 10);
if (uvm_config_db#(int)::exists("", "env.agent", "max_count"))
  n = uvm_config_db#(int)::get("", "env.agent", "max_count");

cdb = uvm_get_config_db();
cdb.set_string("uvm_test_top", "", "mode", "fast");
mode = cdb.get_string("uvm_test_top", "", "mode");
```

Key = `contxt` + `inst_name` + `field_name` joined with `.` (empty parts omitted).

| API | Notes |
|-----|--------|
| `uvm_config_db#(int)::set/exists/get` | Param-class static calls (`C#(T)::method()`); int AA store |
| `ivl_uvm_config_db_box` / `uvm_get_config_db()` | String (+ int) instance helpers |
| Void `Class::method();` as statement | Needed for `::set` |

## Gaps

- `uvm_config_db#(string)` / object-handle resources (int-only static store)
- Wildcard / regex instance paths (`agent.*`)
- Function `output`/`inout` ports (use `exists` + `get` instead of Accellera’s `get(..., inout T)`)
- Hierarchical lookup walking parent scopes

## Example

[`examples/config_db`](../examples/config_db) — prints `PASSED`.

```bash
make -C examples/config_db run
```
