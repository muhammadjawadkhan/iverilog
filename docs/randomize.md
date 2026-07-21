# Unconstrained `randomize()` / `rand` (Tier A #6, first slice)

Status: **partial** — unconstrained integral `rand`/`randc`, plus hard constraints via rejection sampling (see [constraints.md](constraints.md)).

## Supported in this slice

```systemverilog
class pkt;
  rand bit [7:0] a;
  rand bit [3:0] b;
  bit [7:0] c;              // non-rand left alone
  function new(); c = 8'h11; endfunction
endclass

pkt p = new;
bit ok = p.randomize();     // returns 1; assigns random values to a,b
```

- `obj.randomize()` returns `1` on success (null / unknown class type → `0`)
- Assigns random 0/1 bits to all `rand` and `randc` **integral** (`bit`/`logic`/`reg` packed) instance properties
- Non-rand properties are unchanged
- `randc` is treated like `rand` for now (no cyclic guarantee)
- Hard class constraints and `randomize() with { ... }` — see [constraints.md](constraints.md)

## Encoding

| Layer | Role |
|-------|------|
| Parse | `rand`/`randc` property qualifiers; hard `constraint` / `with` kept (soft/dist/`->`/if/foreach → **sorry**) |
| Elab | `obj.randomize()` → `$ivl_randomize(obj [, preds...])` |
| Target API | `ivl_type_prop_rand()` exposes qualifiers to codegen |
| Codegen | `%urandom` + `%store/prop/v`; with preds → rejection loop |
| Runtime | `%urandom` fills vec4 with RNG bits (`std::mt19937`) |

## Deferred (do not claim)

- Soft / dist / implication / if / foreach constraints
- True constraint solver
- `rand_mode` / `constraint_mode`
- True `randc` cyclic behavior
- Randomizing non-integral properties (reals, strings, class handles, arrays)
- `std::randomize` procedural form

## Example

[`examples/randomize/randomize_basic.sv`](../examples/randomize/randomize_basic.sv) — unconstrained; prints `PASSED`.

[`examples/constraints/constraints_basic.sv`](../examples/constraints/constraints_basic.sv) — hard constraints + `with`.

```bash
./install/bin/iverilog -g2012 -o /tmp/rand.vvp examples/randomize/randomize_basic.sv
./install/bin/vvp /tmp/rand.vvp
```

See also [STATUS.md](STATUS.md) and [ROADMAP.md](ROADMAP.md).
