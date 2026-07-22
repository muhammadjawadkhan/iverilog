# Class property method calls

Status: **partial** — `obj.prop.method(...)` elaborates when `prop` is a
class-handle property: the method is resolved on `prop`'s type and `this` is
the property select (`NetEProperty`).

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class inner;
  function void go(int x); endfunction
  function int getx(); return 42; endfunction
endclass
class outer;
  inner ap;
  function new(); ap = new; endfunction
endclass

outer o = new;
o.ap.go(5);        // void / task
n = o.ap.getx();   // function return
```

Also used by the UVM slice: `drv.ap.connect(sb)`, `m_sequencer.put_item(item)`.

## Gaps

- Chains deeper than one property (`a.b.c.method`) not covered
- Non-class property types still use their existing special cases (queues, covergroups, …)

## Related

- [driver.md](driver.md) — `drv.ap.connect`
- [virtual-methods.md](virtual-methods.md) — runtime dispatch once elaborated
