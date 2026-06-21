# File     : Makefile
# Purpose  : makefile for analytic poly subdir

# General make settings

export SH = /bin/bash
export MAKEFLAGS += --no-print-directory

# Variables

SUBDIRS = 0 1 5 5-1

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
