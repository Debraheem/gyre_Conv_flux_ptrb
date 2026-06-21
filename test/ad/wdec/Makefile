# File     : Makefile
# Purpose  : makefile for wdec subdir

# General make settings

export SH = /bin/bash
export MAKEFLAGS += --no-print-directory

# Variables

SUBDIRS = m0.593

# Rules

test :
	@for DIR in $(SUBDIRS); do \
            make -C $$DIR; \
        done

build_ref :
	@for DIR in $(SUBDIRS); do \
            make -C $$DIR $@; \
        done

.PHONY: test build_ref
