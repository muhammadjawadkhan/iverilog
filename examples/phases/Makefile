ROOT      ?= $(abspath ../..)
IVL_UVM_HOME ?= $(ROOT)/uvm
PREFIX    ?= /home/jawad/Desktop/iverilog-uvm/install
IVERILOG  ?= $(PREFIX)/bin/iverilog
VVP       ?= $(PREFIX)/bin/vvp
VVP_MOD   ?= $(PREFIX)/lib/ivl

OUT := phases_basic.vvp

.PHONY: all run clean

all: $(OUT)

$(OUT): phases_basic.sv flist.f
	IVL_UVM_HOME=$(IVL_UVM_HOME) $(IVERILOG) -g2012 -o $@ -c flist.f

run: $(OUT)
	$(VVP) -M $(VVP_MOD) $(OUT)

clean:
	rm -f $(OUT)
