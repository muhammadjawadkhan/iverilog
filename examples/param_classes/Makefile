# Build/run parameterized class smoke tests.

ROOT      ?= $(abspath ../..)
PREFIX    ?= $(ROOT)/install
IVERILOG  ?= $(PREFIX)/bin/iverilog
VVP       ?= $(PREFIX)/bin/vvp
VVP_MOD   ?= $(PREFIX)/lib/ivl

OUTS := box_default.vvp box_special.vvp box_typedef.vvp box_multiparm.vvp box_extends.vvp plain_class.vvp

.PHONY: all run clean

all: $(OUTS)

box_default.vvp: box_default.sv
	$(IVERILOG) -g2012 -o $@ $<

box_special.vvp: box_special.sv
	$(IVERILOG) -g2012 -o $@ $<

box_typedef.vvp: box_typedef.sv
	$(IVERILOG) -g2012 -o $@ $<

box_multiparm.vvp: box_multiparm.sv
	$(IVERILOG) -g2012 -o $@ $<

box_extends.vvp: box_extends.sv
	$(IVERILOG) -g2012 -o $@ $<

plain_class.vvp: plain_class.sv
	$(IVERILOG) -g2012 -o $@ $<

run: all
	$(VVP) -M $(VVP_MOD) box_default.vvp
	$(VVP) -M $(VVP_MOD) box_special.vvp
	$(VVP) -M $(VVP_MOD) box_typedef.vvp
	$(VVP) -M $(VVP_MOD) box_multiparm.vvp
	$(VVP) -M $(VVP_MOD) box_extends.vvp
	$(VVP) -M $(VVP_MOD) plain_class.vvp

clean:
	rm -f $(OUTS)
