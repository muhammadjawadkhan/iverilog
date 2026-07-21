# Hard constraints + `randomize() with` (Tier A #6, rejection slice)

Status: **partial** — hard relational constraints with rejection sampling; no solver.

## Supported in this slice

```systemverilog
class pkt;
  rand bit [3:0] a;
  rand bit [3:0] b;
  constraint c_ab { a < 4; b == a; }
endclass

pkt p = new;
bit ok = p.randomize();              // satisfies c_ab
ok = p.randomize() with { a == 2; }; // also forces a==2 (hence b==2)
```

### Hard constraints

| Form | Behavior |
|------|----------|
| `constraint name { expr; ... }` | Predicates AND'd; must hold after `randomize()` |
| `randomize() with { expr; ... }` | Extra predicates for that call |
| Operators | `==` `!=` `<` `>` `<=` `>=` (operands: rand props or constants); `&&` of those |

### Semantics (rejection sampling)

1. `%urandom`-fill all `rand`/`randc` integral properties
2. Evaluate all class + `with` predicates
3. If any fail, retry (up to **10000** attempts)
4. Return `1` on success, `0` on exhaustion

## Encoding

| Layer | Role |
|-------|------|
| Parse | Keep hard `expression ;` in constraint blocks / `with`; soft/dist/`->`/if/foreach → **sorry** |
| Elab | Predicates → `NetEBComp` / `NetEProperty`; `$ivl_randomize(obj, pred...)` |
| Codegen | Retry loop around `%urandom` + `%store/prop/v` + constraint checks |

## Deferred (do not claim)

- Soft constraints, `dist`, implication, `if`/`else`, `foreach`
- True constraint solver / weighted / `solve...before`
- `rand_mode` / `constraint_mode`
- True `randc` cyclic behavior
- Non-integral rand properties

## Example

[`examples/constraints/constraints_basic.sv`](../examples/constraints/constraints_basic.sv) — prints `PASSED`.

```bash
./install/bin/iverilog -g2012 -o /tmp/c.vvp examples/constraints/constraints_basic.sv
./install/bin/vvp /tmp/c.vvp
```

See also [randomize.md](randomize.md), [STATUS.md](STATUS.md), [ROADMAP.md](ROADMAP.md).
