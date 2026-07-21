// Tier B #1 — Accellera-shaped factory vertical slice for IVL_UVM.
//
// Storage is package-level: class properties cannot hold string fixed-arrays
// or associative arrays on this compiler. Methods on uvm_factory operate on
// the singleton tables (matches Accellera's single global factory).
`ifndef IVL_UVM_FACTORY_SVH
`define IVL_UVM_FACTORY_SVH

`ifndef IVL_UVM_FACTORY_MAX_TYPES
  `define IVL_UVM_FACTORY_MAX_TYPES 64
`endif

`ifndef IVL_UVM_FACTORY_MAX_OVERRIDES
  `define IVL_UVM_FACTORY_MAX_OVERRIDES 32
`endif

uvm_object_wrapper ivl_uvm_fac_types[`IVL_UVM_FACTORY_MAX_TYPES];
int                ivl_uvm_fac_type_idx[string];
int                ivl_uvm_fac_num_types;

string             ivl_uvm_fac_ovr_val[`IVL_UVM_FACTORY_MAX_OVERRIDES];
int                ivl_uvm_fac_ovr_idx[string];
int                ivl_uvm_fac_num_overrides;

class uvm_factory;
  function new(string name = "uvm_factory");
  endfunction

  function void register(uvm_object_wrapper obj);
    string tn;
    int idx;
    tn = obj.type_name;
    if (tn == "" || tn == "<unknown>") begin
      $display("UVM_ERROR @ 0: reporter [FCTREG] Wrapper has empty type_name");
      return;
    end
    idx = ivl_uvm_fac_type_idx[tn];
    if (idx != 0) begin
      ivl_uvm_fac_types[idx-1] = obj;
      return;
    end
    if (ivl_uvm_fac_num_types >= `IVL_UVM_FACTORY_MAX_TYPES) begin
      $display("UVM_ERROR @ 0: reporter [FCTREG] Factory type table full (%0d)",
               `IVL_UVM_FACTORY_MAX_TYPES);
      return;
    end
    ivl_uvm_fac_types[ivl_uvm_fac_num_types] = obj;
    ivl_uvm_fac_type_idx[tn] = ivl_uvm_fac_num_types + 1;
    ivl_uvm_fac_num_types++;
  endfunction

  function uvm_object_wrapper find_by_name(string type_name);
    int idx;
    idx = ivl_uvm_fac_type_idx[type_name];
    if (idx == 0)
      return null;
    return ivl_uvm_fac_types[idx-1];
  endfunction

  function void set_type_override_by_name(string requested_type,
                                          string override_type,
                                          bit replace = 1);
    int idx;
    if (requested_type == "" || override_type == "") return;
    idx = ivl_uvm_fac_ovr_idx[requested_type];
    if (idx != 0) begin
      if (replace)
        ivl_uvm_fac_ovr_val[idx-1] = override_type;
      return;
    end
    if (ivl_uvm_fac_num_overrides >= `IVL_UVM_FACTORY_MAX_OVERRIDES) begin
      $display("UVM_ERROR @ 0: reporter [FCTOVRD] Factory override table full");
      return;
    end
    ivl_uvm_fac_ovr_val[ivl_uvm_fac_num_overrides] = override_type;
    ivl_uvm_fac_ovr_idx[requested_type] = ivl_uvm_fac_num_overrides + 1;
    ivl_uvm_fac_num_overrides++;
  endfunction

  function string resolve_type_name(string requested_type);
    string cur;
    int idx;
    int guard;
    cur = requested_type;
    for (guard = 0; guard < `IVL_UVM_FACTORY_MAX_OVERRIDES; guard++) begin
      idx = ivl_uvm_fac_ovr_idx[cur];
      if (idx == 0) break;
      cur = ivl_uvm_fac_ovr_val[idx-1];
    end
    return cur;
  endfunction

  // Base create calls wrapper.create_object through a base handle — returns
  // null until virtual methods work. Use a $cast helper in the TB (see example).
  function uvm_object create_object_by_name(string requested_type,
                                           string parent_inst_path = "",
                                           string name = "");
    string actual;
    uvm_object_wrapper w;
    actual = resolve_type_name(requested_type);
    w = find_by_name(actual);
    if (w == null) begin
      $display("UVM_ERROR @ 0: reporter [FCTTYP] Type '%s' not registered",
               actual);
      return null;
    end
    return w.create_object(name);
  endfunction

  function uvm_component create_component_by_name(string requested_type,
                                                  string parent_inst_path = "",
                                                  string name,
                                                  uvm_component parent);
    string actual;
    uvm_object_wrapper w;
    actual = resolve_type_name(requested_type);
    w = find_by_name(actual);
    if (w == null) begin
      $display("UVM_ERROR @ 0: reporter [FCTTYP] Type '%s' not registered",
               actual);
      return null;
    end
    return w.create_component(name, parent);
  endfunction

  function void debug_type_list();
    $display("UVM_INFO @ 0: reporter [FCTTYP] %0d registered type(s)",
             ivl_uvm_fac_num_types);
  endfunction
endclass : uvm_factory

uvm_factory factory;

function uvm_factory uvm_get_factory();
  if (factory == null)
    factory = new("factory");
  return factory;
endfunction

`endif // IVL_UVM_FACTORY_SVH
