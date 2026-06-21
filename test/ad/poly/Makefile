# File     : Makefile
# Purpose  : makefile for poly subdir

# General make settings

export SH = /bin/bash
export MAKEFLAGS += --no-print-directory

# Variables

SUBDIRS = 0.0 0.0+0.0 1.5 1.5-no-ctr 3.0 3.0-g 3.0+3.0 3.0+3.0-jump 4.0

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
