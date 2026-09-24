# Eddy viscosity checks

Use an existing schema-130 profile with nonzero convective velocity.
These tests do not run MESA.

After building GYRE, run the native coefficient and transformation checks
and the spherical-tensor identities:

```sh
make check PROFILE=/path/to/gyre.data PYTHON=python3
```

The makefile uses the same default SDK libraries as the GYRE build.
Set `GYRE_DIR` explicitly if the environment points to a different build.
Set `FFLAGS` and `LDLIBS` when testing a build with different libraries.
The tensor test requires SymPy. The mode tests require NumPy and h5py.

`test_support` compares the determinant for BANDED, ROWPP, and CYCLIC,
with OSC and EXP time conventions, for degrees 0 through 3 and both
frozen convection and TDC. Both COLLOC_GL2 and MAGNUS_GL2 are checked.
Manufactured displacement fields check
nonpositive volume dissipation, quadratic amplitude scaling, and zero
loss for rigid translation. These are not discrete energy-balance tests.

For a profile with a radiative core, `make check_regular PROFILE=...`
tests the regular central boundary with `alpha_rht=1`. Positive central
viscosity has a separate regular expansion, implemented in `tdc_visc_m`.
This radiative-core test does not exercise it; positive central viscosity
still requires numerical convergence tests.

The native test also checks frequency-independent horizontal pivots
in inviscid intervals and at an inviscid surface. Eliminating the
algebraic horizontal displacement must recover the ordinary six-variable
midpoint or Magnus equations for degrees 1 through 3 at complex frequencies.
The Magnus check also approaches zero viscosity at a convective point
using `tdc_alpha_M=1d-12`, without a coefficient floor.
The supplied profile must contain an inviscid interval and a viscous
test point.

The coefficient test also checks turbulent energy storage in the local
TDC heat equation. An analytic compression response tests its sign and
normalization in the 2x2 and 3x3 closures for degrees 0 through 3 at
three complex frequencies. Further checks cover inactive convection,
the sixth matrix row, transposed evaluation and `alpha_thm` scaling.
The synthetic 3x3 check does not validate turbulent-pressure equilibrium.

For nonradial Magnus, the differential rows use exponential propagation;
the horizontal reconstruction and implicit shear relation remain second
order. Invoking MAGNUS_GL2 does not enable a nodal eight-variable
propagator or a higher order shear discretization.

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
