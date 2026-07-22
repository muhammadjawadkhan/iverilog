# Virtual method dispatch

Status: **partial** — class methods called through a base handle dispatch to the
runtime type's override. Functions use `%callf/virt/*`; class tasks use
`%callt/virt`. Override scopes get their own automatic storage (ports copied
from the statically elaborated callee). `super.method` is **statically** bound
(no virtual dispatch).

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class base;
  virtual function string get_type_name(); return "base"; endfunction
  virtual task body(); endtask
endclass
class der extends base;
  virtual function string get_type_name(); return "der"; endfunction
  virtual task body();
    super.body(); // static bind — does not recurse into der::body
  endtask
endclass

base b; der d = new; b = d;
s = b.get_type_name(); // "der"
b.body();              // runs der::body → base::body
```

- Object-returning overrides may use locals (scope switch + return copy).
- Int/string/real ports are copied into the override automatic context.
- Constructors (`new`) are **not** virtually dispatched (would recurse).
- Calls to empty base tasks that may be overridden are **not** elided.
- `super.method` forces non-virtual call (`%callf/void` / static task call).

## Gaps / limits

- Non-virtual vs virtual is not distinguished yet for ordinary calls through
  handles — class method calls use runtime lookup (fine when there is no override).
- Does not fix self-call of an override without `super` (e.g. `build()` inside
  `build()` recurses via virt — use `super.build()`).
- Unqualified calls to *inherited* methods from a derived body work.
- Suspending virt calls that switch scopes mid-join are not hardened.

## Example

[`examples/virtual_methods`](../examples/virtual_methods) — prints `PASSED`.
