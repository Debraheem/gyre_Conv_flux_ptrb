# File     : Makefile
# Purpose  : makefile for num subdir

# General make settings

export SH = /bin/bash
export MAKEFLAGS += --no-print-directory

# Variables

SUBDIRS = omp sysmtx_banded sysmtx_cyclic sysmtx_rowpp \
          delta cowling vars-dziem vars-jcd vars-mix vars-lagp \
          diff-colloc diff-magnus diff-mirk diff-trapz \
          lambda-sph lambda-tar-gravity lambda-tar-rossby lambda-adhoc

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
