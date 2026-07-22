// Accellera-shaped uvm_object_registry#(T, Tname) for IVL_UVM.
//
// get() uses `m_inst = new` where m_inst is typed as the base wrapper;
// PENewClass elaborates bare `new` inside a method as the enclosing class
// when that class is compatible with the LHS type.
`ifndef IVL_UVM_REGISTRY_SVH
`define IVL_UVM_REGISTRY_SVH

// Concrete default for the type parameter so the generic class can elaborate
// (uvm_object is virtual and cannot be new'd).
class ivl_uvm_registry_dummy extends uvm_object;
  function new(string name = "ivl_uvm_registry_dummy");
    super.new(name);
  endfunction
  virtual function string get_type_name();
    return "ivl_uvm_registry_dummy";
  endfunction
  virtual function uvm_object create(string name = "");
    return null;
  endfunction
endclass : ivl_uvm_registry_dummy

class uvm_object_registry #(type T = ivl_uvm_registry_dummy,
                            parameter string Tname = "<unknown>")
  extends uvm_object_wrapper;

  static uvm_object_wrapper m_inst;

  function new();
    uvm_factory f;
    super.new(Tname);
    f = uvm_get_factory();
    f.register(this);
  endfunction

  // Accellera-shaped singleton. Call as TYPE::type_id::get().
  // Returns the base wrapper; $cast to TYPE::type_id for typed create.
  static function uvm_object_wrapper get();
    if (m_inst == null)
      m_inst = new;
    return m_inst;
  endfunction

  virtual function uvm_object create_object(string name = "");
    T obj;
    obj = new(name);
    return obj;
  endfunction

  // Accellera-shaped static create: TYPE::type_id::create(name).
  // Goes through get()+create_object so type overrides still apply.
  static function T create(string name = "");
    T obj;
    uvm_object_wrapper w;
    uvm_object tmp;
    bit ok;
    w = get();
    tmp = w.create_object(name);
    ok = $cast(obj, tmp);
    return obj;
  endfunction

endclass : uvm_object_registry

`endif // IVL_UVM_REGISTRY_SVH
