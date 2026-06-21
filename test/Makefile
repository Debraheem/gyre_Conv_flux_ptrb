# File     : Makefile
# Purpose  : makefile for test subdir

# General make settings

export SH = /bin/bash
export MAKEFLAGS += --no-print-directory

# Variables

SUBDIRS = ad nad tides

# Rules

ifneq ($(PORTABLE),yes)
   $(warning Warning: PORTABLE is not set to "yes", some tests may fail)
endif

test :
	@for DIR in $(SUBDIRS); do \
            make -C $$DIR; \
        done

build_ref :
	@for DIR in $(SUBDIRS); do \
            make -C $$DIR $@; \
        done

.PHONY: test build_ref
