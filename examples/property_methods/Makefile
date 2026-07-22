ROOT      ?= $(abspath ../..)
PREFIX    ?= $(ROOT)/install
IVERILOG  ?= $(PREFIX)/bin/iverilog
VVP       ?= $(PREFIX)/bin/vvp
VVP_MOD   ?= $(PREFIX)/lib/ivl
OUT := property_methods_basic.vvp
.PHONY: all run clean
all: $(OUT)
$(OUT): property_methods_basic.sv flist.f
	$(IVERILOG) -g2012 -o $@ -c flist.f
run: $(OUT)
	$(VVP) -M $(VVP_MOD) $(OUT)
clean:
	rm -f $(OUT)
