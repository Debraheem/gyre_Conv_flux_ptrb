# File     : Makefile
# Purpose  : makefile for standard test subdir

# General make settings

export SH = /bin/bash
export MAKEFLAGS += --no-print-directory

# Variables

ifeq ($(DEBUG),yes)
   REF_DIR = ref-debug
else
   REF_DIR = ref
endif

# Rules

test :
	@./test.sh

build_ref :
	@./gyre gyre.in >& /dev/null; \
        for file in summary*.h5; do \
            if [ -e $(REF_DIR)/$$file ]; then \
                if ./h5pydiff.py -q $$file $(REF_DIR)/$$file; then \
                    rm $$file; \
                else \
                    echo "updating $(CURDIR)/$(REF_DIR)/$$file"; \
                    mv $$file $(REF_DIR)/$$file; \
                fi; \
            else \
                echo "creating $(CURDIR)/$(REF_DIR)/$$file"; \
                mv $$file $(REF_DIR)/$$file; \
            fi; \
        done

.PHONY: test build_ref
