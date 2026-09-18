# Eddy viscosity checks

Use an existing schema-130 profile with nonzero convective velocity.
These tests do not run MESA.

After building GYRE, run the native coefficient and transformation checks
and the spherical-tensor identities:

```sh
make check PROFILE=/path/to/gyre.data PYTHON=python3
```

The makefile uses the same default SDK libraries as the GYRE build.
Set `FFLAGS` and `LDLIBS` when testing a build with different libraries.
The tensor test requires SymPy. The mode tests require NumPy and h5py.

The native test also checks frequency-independent horizontal pivots
in inviscid intervals and at an inviscid surface. Eliminating the
algebraic horizontal displacement must recover the ordinary six-variable
midpoint equations for degrees 1 through 3 at complex frequencies.
The supplied profile must contain an inviscid interval and a viscous
test point.

```sh
python3 run_smoke.py --binary ../../bin/gyre \
  --profile /path/to/gyre.data --output /path/to/new/test-output
```

The smoke test compares omitted and zero controls, the profile coefficient
and a `0.15d0` override, and 4000-point and 8000-point grids. For the
coefficient comparison the supplied profile must export `tdc_alpha_M = 0.15`.
An optional `--previous-binary` checks the default against an earlier build.
The interval is `0.1 <= r/R <= 1`; these are outer-envelope code checks,
not a reproduction of a model's full mode spectrum. Both frozen convection
and local TDC are exercised. Frequency seeds span the requested acoustic
orders; failed seeds do not imply absent modes. The full run log is retained.

Before interpreting a mode physically, check its spatial convergence,
inner boundary, and viscous shear-layer resolution. The gravity-wave
criterion alone does not resolve every viscous length scale
`sqrt(nu_t/abs(sigma))`. The free viscous surface must have zero normal
and tangential traction; atmospheric conditions are supported only when
the outer-point viscosity is zero.
