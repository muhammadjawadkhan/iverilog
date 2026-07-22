# Virtual method dispatch

Status: **partial** — class methods called through a base handle dispatch to the
runtime type's override.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class base;
  virtual function string get_type_name(); return "base"; endfunction
endclass
class der extends base;
  virtual function string get_type_name(); return "der"; endfunction
endclass

base b; der d = new; b = d;
s = b.get_type_name(); // "der"
```

Codegen emits `%callf/virt/*` for class methods. VVP looks up the method on
the object's `class_type` (`.cmethod` table) and runs that code using the
statically elaborated callee's automatic storage.

## Gaps / limits

- Override bodies should not rely on locals that do not exist in the base
  method's automatic scope (storage is shared with the static callee).
- Non-virtual vs virtual is not distinguished yet — all class method calls
  through handles use runtime lookup (fine when there is no override).
- Tasks / void methods: same path via `%callf/virt/void`.
- Does not fix “derived body cannot call inherited method by unqualified name”.

## Example

[`examples/virtual_methods`](../examples/virtual_methods) — prints `PASSED`.
