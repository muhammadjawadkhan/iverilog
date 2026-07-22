# Agent / monitor / env (Tier B)

Status: **partial** — thin Accellera-shaped `uvm_monitor`, `uvm_agent`, and
`uvm_env` on top of driver/sequencer/analysis.

Track: **muhammadjawadkhan/iverilog-uvm** only.

## What works

```systemverilog
class my_agent extends uvm_agent;
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase); // static bind — safe
    // replace/extend driver as needed
  endfunction
endclass

agent.monitor.ap.connect(sb);   // nested property method
seq.start(env.agent.sequencer); // nested property read
```

| API | Notes |
|-----|--------|
| `uvm_monitor` | Owns `uvm_analysis_port ap`; virtual `sample_and_write` |
| `uvm_agent` | `is_active`, `sequencer` / `driver` / `monitor`; build + connect |
| `uvm_env` | Empty component shell for holding agents |

## Gaps

- No parameterized agent/monitor
- No multi-agent / virtual sequencer
- Analysis fan-out is on the port (see [driver.md](driver.md)), not a
  separate export/imp hierarchy

## Example

[`examples/agent`](../examples/agent) — prints `PASSED`.
