# config_db (Tier B #2)

Status: **partial** — exact-match `set`/`get`/`exists` for `int` and `string` via `uvm_config_db#(T[,IS_STR])`.

Track: **muhammadjawadkhan/iverilog-uvm** only. Do not open PRs to `steveicarus/iverilog` for this work.

## What works

```systemverilog
uvm_config_db#(int)::set("", "env.agent", "max_count", 10);
n = uvm_config_db#(int)::get("", "env.agent", "max_count");

uvm_config_db#(string, 1)::set("uvm_test_top", "", "mode", "fast");
mode = uvm_config_db#(string, 1)::get("uvm_test_top", "", "mode");
```

String resources use second parameter `IS_STR=1` (`uvm_config_db#(string, 1)::…`). Plain `uvm_config_db#(string)` without `IS_STR` still selects the int store path.

Key = `contxt` + `inst_name` + `field_name` joined with `.` (empty parts omitted).

| API | Notes |
|-----|--------|
| `uvm_config_db#(int)::set/exists/get` | Int AA store |
| `uvm_config_db#(string, 1)::set/exists/get` | String table (IS_STR=1) |
| `ivl_uvm_config_db_box` / `uvm_get_config_db()` | Instance helpers delegating to the above |

## Gaps

- `uvm_config_db#(string)` without `IS_STR=1` (needs type-trait default)
- Object / class-handle resources
- Wildcard / regex instance paths (`agent.*`)
- Hierarchical lookup walking parent scopes

## Example

[`examples/config_db`](../examples/config_db) — prints `PASSED`.

```bash
make -C examples/config_db run
```
