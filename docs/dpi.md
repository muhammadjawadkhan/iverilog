# DPI-C (Tier A #9)

Status: **partial** — `import "DPI-C" function` with scalar `int` args/return.

## Supported in this slice

```systemverilog
import "DPI-C" function int dpi_add(int a, int b);
// optional C name: import "DPI-C" cname = function int dpi_add(...);
```

- Parse + elaborate DPI imports as function prototypes (no SV body)
- Calls lower to `%dpi/call "cname", nargs` and resolve via `dlsym`
- Up to 8 scalar `int` arguments; 32-bit integer return

## Loading the shared library

VPI modules use `vvp -m` and require `vlog_startup_routines`. DPI libraries are plain `.so` files, so this fork adds:

```bash
vvp -d ./dpi_add.so design.vvp
```

`-d` `dlopen`s the library with `RTLD_GLOBAL`. Alternatively:

```bash
LD_PRELOAD=./dpi_add.so vvp design.vvp
```

(The process image is also searched, so preloaded symbols resolve.)

Build the `.so` as a normal shared object (no `vlog_startup_routines` needed):

```bash
gcc -shared -fPIC -o dpi_add.so dpi_add.c
```

Include the stub [`svdpi.h`](../svdpi.h) from the tree (or install prefix after install).

## Encoding

| Layer | Role |
|-------|------|
| Parse | `import "DPI-C" function …;` → `PFunction` with `dpi_c_name` |
| Elab | Calls rewrite to `$ivl_dpi_call$<cname>(…)` system-function expr |
| Codegen | `%dpi/call "cname", nargs` |
| Runtime | `vpip_load_dpi_library` + `vpip_dpi_call_i32` (`vvp/vvp_dpi.{h,cc}`) |

## Deferred (do not claim)

- `export "DPI-C"`
- `context` / `pure`, open arrays, strings, structs, chandles
- `void` / `real` / `byte` / `shortint` / `longint` (easy extensions)
- Automatic `iverilog` linking of C sources (use `-d` / Makefile)

## Example

[`examples/dpi`](../examples/dpi) — prints `PASSED`.

```bash
make -C examples/dpi run
```

See also [STATUS.md](STATUS.md) and [ROADMAP.md](ROADMAP.md).
