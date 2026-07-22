# config_db (Tier B #2)

Status: **partial** — exact-match `set`/`get`/`exists` for `int`, `string`, and object handles via `uvm_config_db#(T[,IS_STR])` / `uvm_config_db_object#(T)`.

Track: **muhammadjawadkhan/iverilog-uvm** only. Do not open PRs to `steveicarus/iverilog` for this work.

## What works

```systemverilog
uvm_config_db#(int)::set("", "env.agent", "max_count", 10);
n = uvm_config_db#(int)::get("", "env.agent", "max_count");

uvm_config_db#(string, 1)::set("uvm_test_top", "", "mode", "fast");
mode = uvm_config_db#(string, 1)::get("uvm_test_top", "", "mode");

// Object handles (T must extend uvm_object). get() returns the typed handle.
uvm_config_db_object#(cfg_item)::set("", "env.agent", "cfg", obj_in);
obj_out = uvm_config_db_object#(cfg_item)::get("", "env.agent", "cfg");
```

String resources use second parameter `IS_STR=1` (`uvm_config_db#(string, 1)::…`) when both int and string specializations appear in one compilation unit. Plain `uvm_config_db#(string)` without `IS_STR` still selects the int store path (static methods do not get per-specialization `$typename(T)` folding when multiple `#()` specializations are compiled together).

Object resources use `uvm_config_db_object#(T)` (a separate class — a class-handle `T` cannot share the int/string store branches). `get()` returns the typed handle (or `null`), rather than Accellera's `ref` out-parameter, because function `ref`/`output` ports are not yet supported; use `exists()` to tell "absent" from a stored `null`. Associative arrays / queues of class handles are unsupported, so the object store uses a fixed array + string-index AA (`IVL_UVM_CONFIG_DB_MAX_OBJECTS`, default 64).

User classes may be declared at `$unit` scope (extending `uvm_object` via `import ivl_uvm_pkg::*`) or in a dedicated package.

Key = `contxt` + `inst_name` + `field_name` joined with `.` (empty parts omitted).

| API | Notes |
|-----|--------|
| `uvm_config_db#(int)::set/exists/get` | Int AA store |
| `uvm_config_db#(string, 1)::set/exists/get` | String table (IS_STR=1) |
| `uvm_config_db_object#(T)::set/exists/get` | Object table; `get` returns typed handle via `$cast` |
| `ivl_uvm_config_db_box` / `uvm_get_config_db()` | Instance helpers delegating to the above |

## Gaps

- `uvm_config_db#(string)` without `IS_STR=1` when int and string specializations compile together (static `$typename(T)` does not fold per specialization in that case; use `#(string, 1)` or a compilation unit with only string uses)
- Object `get()` via Accellera `ref` out-parameter (function `ref`/`output` ports unsupported)
- Wildcard / regex instance paths (`agent.*`)
- Hierarchical lookup walking parent scopes

## Example

[`examples/config_db`](../examples/config_db) — prints `PASSED`.

```bash
make -C examples/config_db run
```
