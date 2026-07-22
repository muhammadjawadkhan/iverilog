// Tier B #2 — Accellera-shaped config_db vertical slice for IVL_UVM.
//
// Exact-match set/get/exists for int and string via uvm_config_db#(T[,IS_STR]).
// String resources use IS_STR=1: uvm_config_db#(string, 1)::set/get/exists.
// Package-level tables (class properties cannot hold AAs / string arrays).
`ifndef IVL_UVM_CONFIG_DB_SVH
`define IVL_UVM_CONFIG_DB_SVH

`ifndef IVL_UVM_CONFIG_DB_MAX_STRINGS
  `define IVL_UVM_CONFIG_DB_MAX_STRINGS 64
`endif

// ---- int resources: string key -> int value ----
int ivl_uvm_cfg_ints[string];

// ---- string resources: key -> index+1 into value table ----
int    ivl_uvm_cfg_str_idx[string];
string ivl_uvm_cfg_str_val[`IVL_UVM_CONFIG_DB_MAX_STRINGS];
int    ivl_uvm_cfg_str_n;

// ---- object resources: key -> index+1 into value table ----
// Associative arrays / queues of class handles are not yet supported, so
// object handles use the same fixed-array + string-index-AA scheme as the
// string table. Values are stored as the base handle; typed get() $casts.
`ifndef IVL_UVM_CONFIG_DB_MAX_OBJECTS
  `define IVL_UVM_CONFIG_DB_MAX_OBJECTS 64
`endif
int        ivl_uvm_cfg_obj_idx[string];
uvm_object ivl_uvm_cfg_obj_val[`IVL_UVM_CONFIG_DB_MAX_OBJECTS];
int        ivl_uvm_cfg_obj_n;

function automatic string ivl_uvm_cfg_make_key(string contxt,
                                               string inst_name,
                                               string field_name);
  string key;
  key = "";
  if (contxt != "") begin
    key = contxt;
    if (inst_name != "" || field_name != "")
      key = {key, "."};
  end
  if (inst_name != "") begin
    key = {key, inst_name};
    if (field_name != "")
      key = {key, "."};
  end
  if (field_name != "")
    key = {key, field_name};
  return key;
endfunction

function automatic void ivl_uvm_cfg_put_string(string key, string value);
  int idx;
  idx = ivl_uvm_cfg_str_idx[key];
  if (idx != 0) begin
    ivl_uvm_cfg_str_val[idx-1] = value;
    return;
  end
  if (ivl_uvm_cfg_str_n >= `IVL_UVM_CONFIG_DB_MAX_STRINGS) begin
    $display("UVM_ERROR @ 0: reporter [CFGDB] string table full");
    return;
  end
  ivl_uvm_cfg_str_val[ivl_uvm_cfg_str_n] = value;
  ivl_uvm_cfg_str_idx[key] = ivl_uvm_cfg_str_n + 1;
  ivl_uvm_cfg_str_n++;
endfunction

function automatic bit ivl_uvm_cfg_has_string(string key);
  return (ivl_uvm_cfg_str_idx[key] != 0);
endfunction

function automatic string ivl_uvm_cfg_get_string(string key);
  int idx;
  idx = ivl_uvm_cfg_str_idx[key];
  if (idx == 0)
    return "";
  return ivl_uvm_cfg_str_val[idx-1];
endfunction

function automatic void ivl_uvm_cfg_put_object(string key, uvm_object value);
  int idx;
  idx = ivl_uvm_cfg_obj_idx[key];
  if (idx != 0) begin
    ivl_uvm_cfg_obj_val[idx-1] = value;
    return;
  end
  if (ivl_uvm_cfg_obj_n >= `IVL_UVM_CONFIG_DB_MAX_OBJECTS) begin
    $display("UVM_ERROR @ 0: reporter [CFGDB] object table full");
    return;
  end
  ivl_uvm_cfg_obj_val[ivl_uvm_cfg_obj_n] = value;
  ivl_uvm_cfg_obj_idx[key] = ivl_uvm_cfg_obj_n + 1;
  ivl_uvm_cfg_obj_n++;
endfunction

function automatic bit ivl_uvm_cfg_has_object(string key);
  return (ivl_uvm_cfg_obj_idx[key] != 0);
endfunction

function automatic uvm_object ivl_uvm_cfg_get_object(string key);
  int idx;
  idx = ivl_uvm_cfg_obj_idx[key];
  if (idx == 0)
    return null;
  return ivl_uvm_cfg_obj_val[idx-1];
endfunction

// Accellera-shaped parameterized API.
// Int:  uvm_config_db#(int)::set/get/exists
// Str:  uvm_config_db#(string, 1)::set/get/exists  (IS_STR=1 selects string store)
class uvm_config_db #(type T = int, bit IS_STR = 0);

  static function void set(string contxt, string inst_name, string field_name,
                           T value);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    if (!IS_STR)
      ivl_uvm_cfg_ints[key] = value;
    else
      ivl_uvm_cfg_put_string(key, value);
  endfunction

  static function bit exists(string contxt, string inst_name, string field_name);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    if (!IS_STR)
      return ivl_uvm_cfg_ints.exists(key);
    else
      return ivl_uvm_cfg_has_string(key);
  endfunction

  static function T get(string contxt, string inst_name, string field_name);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    if (!IS_STR) begin
      if (!ivl_uvm_cfg_ints.exists(key))
        return 0;
      return ivl_uvm_cfg_ints[key];
    end else begin
      return ivl_uvm_cfg_get_string(key);
    end
  endfunction

endclass : uvm_config_db

// Object-handle resources: uvm_config_db_object#(T)::set/get/exists.
// Kept separate from uvm_config_db#(int/string) because a class-handle T
// cannot share the int/string store branches (cross-branch type-check).
// T must extend uvm_object; the base handle is stored and get() $casts it.
// Note: get() returns the typed handle (or null) rather than Accellera's
// `ref` out-parameter, because function ref/output ports are not yet
// supported; use exists() to distinguish "absent" from a stored null.
class uvm_config_db_object #(type T = uvm_object);

  static function void set(string contxt, string inst_name, string field_name,
                           T value);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    ivl_uvm_cfg_put_object(key, value);
  endfunction

  static function bit exists(string contxt, string inst_name, string field_name);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    return ivl_uvm_cfg_has_object(key);
  endfunction

  static function T get(string contxt, string inst_name, string field_name);
    string key;
    uvm_object tmp;
    T value;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    tmp = ivl_uvm_cfg_get_object(key);
    if (tmp == null)
      return null;
    if ($cast(value, tmp))
      return value;
    return null;
  endfunction

endclass : uvm_config_db_object

// Non-param instance helpers for older call sites.
class ivl_uvm_config_db_box;
  function new(string name = "ivl_uvm_config_db_box");
  endfunction

  function void set_int(string contxt, string inst_name, string field_name,
                        int value);
    uvm_config_db#(int)::set(contxt, inst_name, field_name, value);
  endfunction

  function bit exists_int(string contxt, string inst_name, string field_name);
    return uvm_config_db#(int)::exists(contxt, inst_name, field_name);
  endfunction

  function int get_int(string contxt, string inst_name, string field_name);
    return uvm_config_db#(int)::get(contxt, inst_name, field_name);
  endfunction

  function void set_string(string contxt, string inst_name, string field_name,
                           string value);
    uvm_config_db#(string, 1)::set(contxt, inst_name, field_name, value);
  endfunction

  function bit exists_string(string contxt, string inst_name, string field_name);
    return uvm_config_db#(string, 1)::exists(contxt, inst_name, field_name);
  endfunction

  function string get_string(string contxt, string inst_name, string field_name);
    return uvm_config_db#(string, 1)::get(contxt, inst_name, field_name);
  endfunction
endclass : ivl_uvm_config_db_box

ivl_uvm_config_db_box uvm_config_db_inst;

function ivl_uvm_config_db_box uvm_get_config_db();
  if (uvm_config_db_inst == null)
    uvm_config_db_inst = new("ivl_uvm_config_db_box");
  return uvm_config_db_inst;
endfunction

typedef ivl_uvm_config_db_box uvm_config_db_inst_t;

`endif // IVL_UVM_CONFIG_DB_SVH
