# Covergroups (Tier A #8)

Status: **partial** — minimal embedded covergroup with `sample()` and `get_inst_coverage()`.

## Supported in this slice

```systemverilog
class cov;
  bit [1:0] v;
  covergroup cg;
    coverpoint v {
      bins lo = {0,1};
      bins hi = {2,3};
    }
  endgroup
  function new();
    cg = new;
  endfunction
endclass

cov c = new;
c.v = 0; c.cg.sample();
c.v = 3; c.cg.sample();
real r = c.cg.get_inst_coverage();  // percentage 0..100
```

- Class-embedded `covergroup` / `coverpoint` / `bins = { const,... }`
- `cg = new` inside the enclosing class constructor (binds to `this`)
- `sample()` marks bins whose value list matches the coverpoint property
- `get_inst_coverage()` returns `(bins_hit / bins_total) * 100.0`

## Encoding

| Layer | Role |
|-------|------|
| Parse | `covergroup` as class item; coverpoint + bins lists |
| Netlist | Empty `netclass_t` flagged as covergroup + bin table |
| Elab | `$ivl_covergroup$new(this, …)`, `$ivl_covergroup$sample`, `$ivl_covergroup$get_inst_coverage` |
| Codegen | `%cov/new`, `%cov/sample`, `%cov/get_inst` |
| Runtime | `vvp_covergroup` (`vvp/vvp_covergroup.{h,cc}`) |

## Deferred (do not claim)

- `cross`, `illegal_bins`, `ignore_bins`, `at_least`, `option.*`
- Auto-bins / default bins / wildcard bins / bin ranges (`[low:high]`)
- Module-level (non-embedded) covergroups
- `get_coverage` / `set_inst_name` / coverage database / dump
- Clocking / `with function sample` / iff guards
- Coverpoint expressions other than a simple enclosing-class property name

## Example

[`examples/covergroup/covergroup_basic.sv`](../examples/covergroup/covergroup_basic.sv) — prints `PASSED`.

```bash
./install/bin/iverilog -g2012 -o /tmp/cg.vvp examples/covergroup/covergroup_basic.sv
./install/bin/vvp /tmp/cg.vvp
```

See also [STATUS.md](STATUS.md) and [ROADMAP.md](ROADMAP.md).
