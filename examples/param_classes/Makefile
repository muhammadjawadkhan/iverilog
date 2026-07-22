# Build/run parameterized class smoke tests.

ROOT      ?= $(abspath ../..)
PREFIX    ?= $(ROOT)/install
IVERILOG  ?= $(PREFIX)/bin/iverilog
VVP       ?= $(PREFIX)/bin/vvp
VVP_MOD   ?= $(PREFIX)/lib/ivl

OUTS := box_default.vvp box_special.vvp plain_class.vvp

.PHONY: all run clean

all: $(OUTS)

box_default.vvp: box_default.sv
	$(IVERILOG) -g2012 -o $@ $<

box_special.vvp: box_special.sv
	$(IVERILOG) -g2012 -o $@ $<

plain_class.vvp: plain_class.sv
	$(IVERILOG) -g2012 -o $@ $<

run: all
	$(VVP) -M $(VVP_MOD) box_default.vvp
	$(VVP) -M $(VVP_MOD) box_special.vvp
	$(VVP) -M $(VVP_MOD) plain_class.vvp

clean:
	rm -f $(OUTS)
