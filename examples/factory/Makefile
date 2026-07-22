# Build/run factory smoke test against this tree's install + seeded uvm/.

ROOT      ?= $(abspath ../..)
IVL_UVM_HOME ?= $(ROOT)/uvm
PREFIX    ?= $(ROOT)/install
IVERILOG  ?= $(PREFIX)/bin/iverilog
VVP       ?= $(PREFIX)/bin/vvp
VVP_MOD   ?= $(PREFIX)/lib/ivl

OUT := factory_basic.vvp
OUT_SINGLETON := factory_singleton.vvp

.PHONY: all run run-singleton clean

all: $(OUT)

$(OUT): factory_basic.sv flist.f
	IVL_UVM_HOME=$(IVL_UVM_HOME) $(IVERILOG) -g2012 -o $@ -c flist.f

$(OUT_SINGLETON): factory_singleton.sv flist_singleton.f
	IVL_UVM_HOME=$(IVL_UVM_HOME) $(IVERILOG) -g2012 -o $@ -c flist_singleton.f

run: $(OUT)
	$(VVP) -M $(VVP_MOD) $(OUT)

run-singleton: $(OUT_SINGLETON)
	$(VVP) -M $(VVP_MOD) $(OUT_SINGLETON)

clean:
	rm -f $(OUT) $(OUT_SINGLETON)
