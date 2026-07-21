// Tier B #2 — Accellera-shaped config_db vertical slice for IVL_UVM.
//
// Exact-match set/get/exists for int and string. No wildcards, no
// uvm_config_db#(T) (needs C#(T) specialization). Package-level tables
// (class properties cannot hold AAs / string arrays). Functions cannot
// take output ports — get returns the value; use exists first.
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

class uvm_config_db;
  function new(string name = "uvm_config_db");
  endfunction

  // ---- int ----
  function void set_int(string contxt, string inst_name, string field_name,
                        int value);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    ivl_uvm_cfg_ints[key] = value;
  endfunction

  function bit exists_int(string contxt, string inst_name, string field_name);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    return ivl_uvm_cfg_ints.exists(key);
  endfunction

  function int get_int(string contxt, string inst_name, string field_name);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    if (!ivl_uvm_cfg_ints.exists(key))
      return 0;
    return ivl_uvm_cfg_ints[key];
  endfunction

  // ---- string ----
  function void set_string(string contxt, string inst_name, string field_name,
                           string value);
    string key;
    int idx;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
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

  function bit exists_string(string contxt, string inst_name, string field_name);
    string key;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    return (ivl_uvm_cfg_str_idx[key] != 0);
  endfunction

  function string get_string(string contxt, string inst_name, string field_name);
    string key;
    int idx;
    key = ivl_uvm_cfg_make_key(contxt, inst_name, field_name);
    idx = ivl_uvm_cfg_str_idx[key];
    if (idx == 0)
      return "";
    return ivl_uvm_cfg_str_val[idx-1];
  endfunction
endclass : uvm_config_db

uvm_config_db uvm_config_db_inst;

function uvm_config_db uvm_get_config_db();
  if (uvm_config_db_inst == null)
    uvm_config_db_inst = new("uvm_config_db");
  return uvm_config_db_inst;
endfunction

`endif // IVL_UVM_CONFIG_DB_SVH
