# Class property method calls

Status: **partial** — `obj.prop.method(...)` and multi-level chains
`obj.a.b.method(...)` elaborate when intermediate names are class-handle
properties. Nested property *reads* (`x = obj.a.b`) are supported the same way.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class leaf;
  function void go(int x); endfunction
  function int getx(); return 42; endfunction
endclass
class mid;
  leaf ap;
  function new(); ap = new; endfunction
endclass
class outer;
  mid m;
  function new(); m = new; endfunction
endclass

outer o = new;
o.m.ap.go(5);        // void / task via chain
n = o.m.ap.getx();   // function return via chain
mid t = o.m;         // nested property read
```

Also used by the UVM slice: `agent.monitor.ap.connect(sb)`,
`env.agent.sequencer`.

## Gaps

- Intermediate non-class properties (queue/struct mid-path) still limited
- Nested *l-value* stores (`obj.a.b = x`) not hardened beyond existing cases

## Related

- [agent.md](agent.md) — nested agent/monitor paths
- [driver.md](driver.md) — `drv.ap.connect`
- [virtual-methods.md](virtual-methods.md) — runtime dispatch once elaborated
