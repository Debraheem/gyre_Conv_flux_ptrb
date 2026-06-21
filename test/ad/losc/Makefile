# File     : Makefile
# Purpose  : makefile for losc subdir

# General make settings

export SH = /bin/bash
export MAKEFLAGS += --no-print-directory

# Variables

SUBDIRS = rgb

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
