# Build/run DPI-C import smoke test against this tree's install.

ROOT      ?= $(abspath ../..)
PREFIX    ?= $(ROOT)/install
IVERILOG  ?= $(PREFIX)/bin/iverilog
VVP       ?= $(PREFIX)/bin/vvp
VVP_MOD   ?= $(PREFIX)/lib/ivl
CC        ?= gcc

OUT   := dpi_basic.vvp
DPI_SO := dpi_add.so

.PHONY: all run clean

all: $(OUT) $(DPI_SO)

$(DPI_SO): dpi_add.c
	$(CC) -shared -fPIC -I$(PREFIX)/include/iverilog -I$(ROOT) -o $@ $<

$(OUT): dpi_basic.sv
	$(IVERILOG) -g2012 -o $@ $<

run: all
	$(VVP) -M $(VVP_MOD) -d ./$(DPI_SO) $(OUT)

clean:
	rm -f $(OUT) $(DPI_SO)
