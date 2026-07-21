# Build/run factory smoke test against this tree's install + seeded uvm/.

ROOT      ?= $(abspath ../..)
IVL_UVM_HOME ?= $(ROOT)/uvm
PREFIX    ?= $(ROOT)/install
IVERILOG  ?= $(PREFIX)/bin/iverilog
VVP       ?= $(PREFIX)/bin/vvp
VVP_MOD   ?= $(PREFIX)/lib/ivl

OUT := factory_basic.vvp

.PHONY: all run clean

all: $(OUT)

$(OUT): factory_basic.sv flist.f
	IVL_UVM_HOME=$(IVL_UVM_HOME) $(IVERILOG) -g2012 -o $@ -c flist.f

run: $(OUT)
	$(VVP) -M $(VVP_MOD) $(OUT)

clean:
	rm -f $(OUT)
