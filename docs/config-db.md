# config_db (Tier B #2)

Status: **partial** — exact-match `set`/`get`/`exists` for `int` and `string` on the seeded IVL_UVM layer.

Track: **muhammadjawadkhan/iverilog-uvm** only. Do not open PRs to `steveicarus/iverilog` for this work.

## What works

```systemverilog
cdb = uvm_get_config_db();
cdb.set_int("", "env.agent", "max_count", 10);
if (cdb.exists_int("", "env.agent", "max_count"))
  n = cdb.get_int("", "env.agent", "max_count");

cdb.set_string("uvm_test_top", "", "mode", "fast");
mode = cdb.get_string("uvm_test_top", "", "mode");
```

Key = `contxt` + `inst_name` + `field_name` joined with `.` (empty parts omitted).

| API | Notes |
|-----|--------|
| `set_int` / `exists_int` / `get_int` | `int` resources via `int aa[string]` |
| `set_string` / `exists_string` / `get_string` | string table (AA index + fixed value array) |
| `uvm_get_config_db()` | Package singleton |

## Gaps

- `uvm_config_db#(T)::set/get` (needs parameterized-class specialization + class `::` static calls)
- Wildcard / regex instance paths (`agent.*`)
- Object / class-handle resources
- Function `output`/`inout` ports (use `exists` + `get` instead of Accellera’s `get(..., inout T)`)
- Hierarchical lookup walking parent scopes

## Example

[`examples/config_db`](../examples/config_db) — prints `PASSED`.

```bash
make -C examples/config_db run
```
