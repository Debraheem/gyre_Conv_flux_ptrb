# File    : Makefile
# Purpose : eddy-viscosity coefficient and tensor checks

GYRE_DIR ?= $(abspath ../..)
PYTHON ?= python3
FC = gfortran
PKGS = lapack lapack95 hdf5_fortran odepack blas crmath
PKG_FLAGS = --with-path=$(GYRE_DIR)/lib/pkgconfig --define-variable=math_slot=crmath
FFLAGS = -fopenmp -ffpe-trap=invalid,zero,overflow -I$(GYRE_DIR)/build -I$(GYRE_DIR)/src/forum/build
LDLIBS = -L$(GYRE_DIR)/lib -lgyre -lforum $(shell pkgconf $(PKG_FLAGS) --libs $(PKGS))

test_coefficients: test_coefficients.f90 $(GYRE_DIR)/lib/libgyre.a
	$(FC) $(FFLAGS) $< $(LDLIBS) -o $@

test_support: test_support.f90 $(GYRE_DIR)/lib/libgyre.a
	$(FC) $(FFLAGS) $< $(LDLIBS) -o $@

check: test_coefficients test_support
	./test_coefficients "$(PROFILE)"
	./test_support "$(PROFILE)" 0
	./test_support "$(PROFILE)" 0 envelope MAGNUS_GL2
	$(PYTHON) test_tensor.py

check_regular: test_support
	./test_support "$(PROFILE)" 1 regular
	./test_support "$(PROFILE)" 1 regular MAGNUS_GL2

.PHONY: check check_regular
