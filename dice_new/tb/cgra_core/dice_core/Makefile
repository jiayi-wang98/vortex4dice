.PHONY: sim gen clean

SHELL := /bin/bash

TB ?= tb_dice_core
DICE_HOME ?= $(shell cd ../../.. && pwd)
TEST_VECTOR ?= kernel_simple
MEM_DATA_WIDTH ?= 2048

gen:
	@echo "Generating .mem files from $(TEST_VECTOR).json"
	@python3 $(DICE_HOME)/tb/test_vectors/gen_memfile.py \
		$(DICE_HOME)/tb/test_vectors/$(TEST_VECTOR).json \
		--mem-data-width $(MEM_DATA_WIDTH) \
		--output-dir .

sim: gen
	@echo "Running VCS sim with TOP=$(TB)"
	@TB_TOP=$(TB) DICE_HOME=$(DICE_HOME) tclsh run_vcs.tcl

clean:
	@echo "Cleaning VCS + Verdi artifacts (but keeping novas.conf / novas.rc)..."
	@rm -rf simv \
	        simv.daidir \
	        csrc \
	        DVEfiles \
	        AN.DB \
	        ucli.key \
	        verdiLog \
	        *.fsdb \
	        *.fsdb.* \
	        *.vpd \
	        *.log \
	        *.key \
	        *_meta.mem \
	        *_cta_desc.mem
	@echo "Done."
