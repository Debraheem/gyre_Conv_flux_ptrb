.. _osc-conv:

.. nml:group:: osc
   :no-target:

Convection Effects
==================

The oscillation equations presented in the preceding sections neglect
the thermal and mechanical effects of convection. GYRE provides
functionality for controlling how the thermal effects are suppressed,
and how the mechanical effects can be included in a limited way.

.. _osc-conv-frozen:

Frozen Convection
-----------------

In the derivation of the :ref:`linearized equations
<osc-linear-eqns>`, a term :math:`\delta (\rho^{-1} \nabla \cdot
\vFcon)` is dropped from the perturbed heat equation. This is known as
a *frozen convection* approximation, and is grounded in the assumption
that the energy transport by convection remains unaffected affected by
the pulsation. There's more than one way to freeze convection;
:ads_citet:`pesnell:1990` presents a systematic review of different
approaches. GYRE currently implements a subset of these:

* Pesnell's case 1, neglecting :math:`\delta (\rho^{-1} \nabla \cdot \vFcon)` in the perturbed heat equation.
* Pesnell's case 4, neglecting :math:`\delta \Lcon` (the Lagrangian
  perturbation to the convective luminosity) in the perturbed heat
  equation.

For further details, see the :nml:option:`conv_scheme
<osc.conv_scheme>` option of the :nml:group:`osc` namelist group.

Horizontal Convective Heat Flux
-------------------------------

For MESA-format version-1.30 models, GYRE can include the horizontal component
of the isotropic convective heat-flux perturbation. The scalar diffusion law
is :math:`\vF_{\rm conv}=-\rho T D_{{\rm conv},h}\nabla S`, where
:math:`S` is specific entropy. The background entropy diffusivity
:math:`D_h\equiv D_{{\rm conv},h}` is exported as ``tdc_D_h`` in
units of :math:`\mathrm{cm^2\,s^{-1}}`. MESA infers it from

.. math::

   D_h=\frac{L_{{\rm conv},0}H_P}
   {4\pi r^2\rho T c_P(\nabla_T-\nabla_L)}.

This value is zero unless the numerator and denominator are positive.
For uniform composition the radial entropy gradient is
:math:`\deriv{S_0}{r}=-c_P(\nabla_T-\nabla_{\rm ad})/H_P`.
Thus the radial closure uses the same scalar diffusivity; its explicit
:math:`c_P/H_P` comes from the entropy gradient.

The horizontal spatial gradient is

.. math::

   \nabla_h=\frac{\hat{\boldsymbol\theta}}{r}\frac{\partial}{\partial\theta}
   +\frac{\hat{\boldsymbol\phi}}{r\sin\theta}\frac{\partial}{\partial\phi}
   =\frac{1}{r}\nabla_\Omega.

It has units of inverse length; :math:`\nabla_\Omega` is the dimensionless
angular gradient on the unit sphere. For a separated scalar amplitude,
:math:`\nabla_h(fY_{\ell m})=(f/r)\nabla_\Omega Y_{\ell m}`. This is
distinct from the dimensionless temperature gradient :math:`\nabla_T`.
The Eulerian horizontal flux perturbation is

.. math::

   \vF'_{{\rm conv},h} = - \rho T D_{{\rm conv},h} \nabla_h S',
   \qquad S'=\delta S-\xi_r\deriv{S_0}{r}.

For separated amplitudes, the Lagrangian flux is

.. math::

   \delta F_{{\rm conv},h}
   =-\frac{\rho T D_{{\rm conv},h}}{r}\delta S
    +\frac{F_{{\rm conv},0}}{r}(\xi_h-\xi_r).

The heat equation cancels the :math:`\xi_h` projection term and retains

.. math::

   H_{{\rm conv},h}
   =-\lambda\frac{TD_{{\rm conv},h}}{r^2}\delta S
    -\lambda\frac{F_{{\rm conv},0}}{\rho r^2}\xi_r.

This contributes :math:`-\alphahfc\lambda(\chfc y_5+c_{\rm conv}y_1)` to
the :math:`y_6` equation, where
:math:`c_{\rm conv}=L_{{\rm conv},0}/(L_\star x^3)` uses the exported
convective luminosity. Both terms vanish for radial modes. The
:nml:option:`alpha_hfc <osc.alpha_hfc>` option scales both terms.

The horizontal term can be used with either frozen-convection scheme. With
:nml:option:`conv_scheme <osc.conv_scheme>` set to
:nml:value:`'PERTURBED_TDC_LOCAL'`, GYRE also evaluates the radial convective
luminosity perturbation and the TDC velocity equation. In this case :math:`y_6`
represents the total luminosity perturbation, and a local two-by-two system
determines :math:`\delta\nabla` and :math:`\delta A`.

Local TDC Velocity Equation
---------------------------

The specific turbulent energy is :math:`e_t=A^2`, with
:math:`A=v_{\rm conv}/\sqrt{2/3}`. Define the source in its velocity
equation by

.. math::

   {\rm rhs}_A=S_0-AD_R-A^2D.

The terms represent buoyancy, radiative loss, and turbulent dissipation,
respectively; each has units of acceleration. With
:math:`\Lambda=\alpha_{\rm MLT}H_P`, their coefficients are

.. math::

   S_0=\frac12\sqrt{\frac23}\alpha_S\alpha_{\rm MLT}
       \frac{c_PT}{H_P}\nabla_{\rm ad}Y_{\rm env},\qquad
   D=\frac83\sqrt{\frac23}\frac{\alpha_D}{\Lambda},

.. math::

   D_R=4\sigma_{\rm SB}
       \left(\frac{2\sqrt3\alpha_R}{\Lambda}\right)^2
       \frac{T^3}{\rho^2c_P\kappa}.

Here :math:`\sigma_{\rm SB}` is the Stefan-Boltzmann constant, and
:math:`Y_{\rm env}` is the superadiabaticity with MESA's optional MLT
correction. With no turbulent energy transport, the material energy
equation is

.. math::

   \frac{{\rm D}A^2}{{\rm D}t}
   +P_t^{\rm work}\frac{{\rm D}(1/\rho)}{{\rm D}t}
   =A\,{\rm rhs}_A,\qquad
   P_t^{\rm work}=\alpha_{P{\rm t}}x_{\rm ALFAP}\rho A^2,
   \qquad x_{\rm ALFAP}=2/3.

Here :math:`{\rm D}/{\rm D}t` follows a fluid element. About a static
background, Lagrangian perturbations proportional to :math:`\exp(st)`
satisfy

.. math::

   \delta{\rm rhs}_A
   =s\left(2\delta A-\alpha_{P{\rm t}}x_{\rm ALFAP}A_0
                         \frac{\delta\rho}{\rho_0}\right).

The two terms on the right describe turbulent energy storage and
compression work. MESA's ``set_TDC_LNA`` supplies their coefficients
through derivatives of

.. math::

   I_A=2A+\alpha_{P{\rm t}}x_{\rm ALFAP}A_0\rho_0/\rho,

holding :math:`A_0,\rho_0` fixed. Thus
:math:`\delta{\rm rhs}_A=s\delta I_A`. This auxiliary function has
units of velocity and is not the mode inertia. Only its derivatives
enter the linear system, not its equilibrium value. GYRE constructs
the same storage coefficients directly. The work coefficient
:math:`\alpha_{P{\rm t}}` is distinct from ``mlt_Pturb_factor`` below.

Local TDC Turbulent Pressure
----------------------------

Version-1.30 MESA models provide ``mlt_Pturb_factor`` and the corresponding
background turbulent pressure. Define

.. math::

   P_{\rm eos} = P_{\rm gas} + P_{\rm rad}, \qquad
   P_{\rm tot} = P_{\rm eos} + P_{\rm turb}.

The turbulent-pressure normalization is the one used by MESA's momentum and
radial-LNA equations:

.. math::

   P_{{\rm turb},0} = f_{\rm Pt}\rho v_{\rm conv}^{2}/3,

where :math:`f_{\rm Pt}` is ``mlt_Pturb_factor``. The TDC velocity variable is
:math:`A = v_{\rm conv}/\sqrt{2/3}`,

.. math::

   P_{{\rm turb},0} = f_{\rm Pt}\rho (2/3)A_{0}^{2}/3.

The turbulent-pressure perturbation follows from the same local closure as
:math:`\delta A`:

.. math::

   \frac{\delta P_{\rm turb}}{P_{\rm eos}}
   =
   \frac{P_{{\rm turb},0}}{P_{\rm eos}}
   \left(\frac{\delta\rho}{\rho} + 2\frac{\delta A}{A_{0}}\right).

This expression is the isotropic Kuhfuss turbulent-pressure perturbation
associated with the local TDC velocity closure. It is distinct from the
:math:`\alpha_{P{\rm t}}` term in the TDC velocity equation, which represents
the turbulent-pressure inertia/work correction.

When :nml:option:`tdc_include_Pturb <osc.tdc_include_Pturb>` is
:nml:value:`.FALSE.`, the local TDC branch uses the two-by-two system. When the
option is :nml:value:`.TRUE.` and :math:`P_{{\rm turb},0}` is nonzero, the local
routine uses separate pressure variables for radial and nonradial modes.
Define the pressure coordinate and EOS variables, with :math:`p=x^{\ell-2}`,

.. math::

   q_{1} = \xi_{r}/r, \qquad
   q_{S} = \delta S/c_{P}, \qquad
   q_{2{\rm tot}} = pV(y_2-y_1), \qquad
   q_{2{\rm eos}} = \delta P_{\rm eos}/P_{\rm eos}.

The density perturbation obtained from the EOS is

.. math::

   q_{4{\rm eos}} = q_{2{\rm eos}}/\Gamma_{1} - \upsT q_{S}.

With

.. math::

   \beta_{\rm turb} = P_{{\rm turb},0}/P_{\rm eos}, \qquad
   D_{\rm turb} = \deriv{\ln P_{{\rm turb},0}}{\ln r},

the implemented pressure split is

.. math::

   q_{2{\rm tot}} =
   q_{2{\rm eos}} +
   \beta_{\rm turb}\left(q_{4{\rm eos}} + 2\frac{\delta A}{A_{0}}
   - D_{\rm turb}q_{1}\right).

Together with the total luminosity equation

.. math::

   \delta L =
   \delta L_{\rm rad} + \delta L_{\rm conv}

and the local TDC velocity equation

.. math::

   \delta \dot{A}_{\rm rhs}
   =
   s_{\rm GYRE}\,\delta \dot{A}_{\rm inertia},

this gives a local three-by-three system for :math:`q_{2{\rm eos}}`,
:math:`\delta\nabla`, and :math:`\delta A`. The pressure-force terms use
:math:`q_{2{\rm tot}}`. The EOS, buoyancy, Poisson density source, and thermal
source terms use :math:`q_{2{\rm eos}}`.

Primes denote Eulerian perturbations and :math:`\delta` denotes Lagrangian
perturbations. Since

.. math::

   P'_{\rm turb}=\delta P_{\rm turb}-\xi_r\deriv{P_{{\rm turb},0}}{r},

the local split uses :math:`q_{2{\rm tot}}` as the mixed combination
:math:`(\delta P_{\rm eos}+P'_{\rm turb})/P_{\rm eos}`, not as the
all-Lagrangian total pressure. It equals :math:`pV(y_2-y_1)` for total
Eulerian :math:`y_2` when :math:`dP_{{\rm eos},0}/dr=-\rho g`.
For total-pressure equilibrium, the same coordinate instead equals
:math:`\delta P_{\rm tot}/P_{\rm eos}`. The local solve does not replace
the standard GYRE background or pressure boundary conditions.

After the local solve, set

.. math::

   d=\frac{q_{2{\rm eos}}-q_{2{\rm tot}}}{pV}.

The change in :math:`\delta\rho/(p\rho)` is :math:`(V/\Gamma_1)d`.
The radial momentum row therefore receives :math:`-(V/\Gamma_1)d`.
Both normal and transposed matrix evaluations use this coefficient.

Turbulent Energy Storage
^^^^^^^^^^^^^^^^^^^^^^^^

The local TDC scheme includes the specific turbulent energy perturbation
:math:`\delta e_t=2A_0\delta A` in the thermal equation. On a static
background the storage term is :math:`s(T\delta S+\delta e_t)`, with
:math:`s=-\mathrm{i}\sigma`. The local closure supplies :math:`\delta A`
for both the two-by-two and three-by-three systems.

Define :math:`\omega_{\rm dyn}=\sqrt{GM_\star/R_\star^3}`,
:math:`p=x^{\ell-2}`, and :math:`\delta A=\sum_j a_j y_j`. The addition
to the sixth row of :math:`x\,dy/dx` is

.. math::

   \Delta A_{6j}=\alpha_{\rm thm}\,\mathrm{i}\omega_c
   \frac{4\pi\rho R_\star^3\omega_{\rm dyn}}{L_\star}
   \frac{2A_0 a_j}{p}.

**Turbulent energy storage is always included with**
``conv_scheme = 'PERTURBED_TDC_LOCAL'``.
It uses the existing local velocity response and needs no additional
profile columns or differential unknowns. The frequency convention is
the same as for ordinary entropy storage. The existing
:nml:option:`alpha_thm <osc.alpha_thm>` scales both terms. The viscous
equations retain this row under their stress-variable transformation.
Frozen-convection and adiabatic equations are unchanged.

Matching MESA's thermal storage requires
``TDC_include_eturb_in_energy_equation = .true.`` and
``star_LNA_perturb_turbulent_energy = .true.``. The local velocity equation
has its own storage term :math:`s\delta I_A`; eliminating that equation
supplies :math:`\delta A` but does not replace the heat equation.

Omitted Closure Responses
^^^^^^^^^^^^^^^^^^^^^^^^^

**The following closure responses are not implemented.** They are needed
to reproduce the corresponding MESA ``star_LNA`` linearization, rather
than the fixed-coefficient approximation used here. No input control
enables these missing terms.

The implemented local linearization holds :math:`c_P`, :math:`H_P`,
:math:`\nabla_{\rm L}`, :math:`\nabla_{\rm ad}`, and
the reconstructed ratio :math:`Y_{\rm env}/Y` fixed at their profile values.
It includes the exported opacity derivatives in the radiative and TDC damping
terms.

For the ordinary mixing length, :math:`\alpha_{\rm MLT}` is constant in
both GYRE and MESA's radial ``star_LNA`` calculation. The omitted responses
are derivatives of the closure factors, not perturbations of that parameter.
For example, the full MLT-correction differential is

.. math::

   \delta Y_{\rm env}
   = \frac{\Gamma}{1+\Gamma}(\delta\nabla-\delta\nabla_{\rm L})
   + \frac{Y}{(1+\Gamma)^2}\delta\Gamma.

The local GYRE approximation retains only
:math:`[Y_{\rm env}/Y]\delta\nabla`. MESA also differentiates
:math:`c_P`, the scale height and mixing length, and
:math:`\nabla_{\rm ad}` inside the nonlinear convection closure. The
efficiency response depends on EOS derivatives of :math:`\chi_T` and
:math:`\chi_\rho`. These independent thermodynamic derivatives are not
provided by the current schema-130 background columns and cannot generally
be inferred from radial profile slopes.

In an already linearized EOS identity, coefficient perturbations multiply
another first order perturbation and are discarded. Within the nonlinear
convection closure, these coefficients multiply nonzero equilibrium factors,
so their differentials contribute at first order.

Other Restrictions
^^^^^^^^^^^^^^^^^^

The local TDC branch cannot be combined with
:nml:option:`alpha_trb <osc.alpha_trb>` or with inhomogeneous forcing. GYRE
stops with an error for either combination.

The standard MESA structure coefficients in the model continue to use
:math:`P_{\rm eos}`. The local turbulent-pressure option changes the pressure
perturbation split, but it does not reconstruct background hydrostatic
coefficients or the outer pressure boundary condition using
:math:`P_{\rm tot}`.

Eddy viscosity is selected separately through
:nml:option:`tdc_alpha_M <osc.tdc_alpha_M>` and is described below.

Harmonic mixing-length support is deferred. Current matched MESA comparisons
require ``harmonic_dissipation_length_beta = 0`` and use
:math:`\Lambda=\alpha_{\rm MLT}H_P`.

.. _osc-conv-visc:

Kuhfuss Eddy Viscosity
----------------------

The radial and nonradial extension includes stress equations, central
and envelope boundary conditions, segment matching, matrix solver
support, and viscous work output. The active viscous problem supports
``BANDED``, ``ROWPP``, and ``CYCLIC`` matrix solvers, both time
conventions, and nonzero ``alpha_rht``. The spatial discretizations are
``COLLOC_GL2`` and the partitioned ``MAGNUS_GL2`` method described below.
Neither ``MAGNUS_GL4`` nor ``COLLOC_GL4`` is implemented for active viscosity.
This is an implementation limit, not a physical restriction on the
stress law. With zero viscosity throughout the model, the ordinary
GYRE discretizations remain available. See
:nml:option:`tdc_alpha_M <osc.tdc_alpha_M>` for the other restrictions.

The kinematic viscosity is

.. math::

   \nu_t = \alpha_M\Lambda A_0,\qquad
   \Lambda = \alpha_{\rm MLT}H_P,\qquad
   A_0 = \frac{\mathrm{mlt\_vc}}{\sqrt{2/3}}.

The background quantities are supplied by the version-1.30 MESA
profile. The :nml:option:`tdc_alpha_M <osc.tdc_alpha_M>` control selects
the coefficient. No viscosity floor is applied.

For pulsation velocity :math:`\mathbf u=-{\rm i}\sigma\boldsymbol\xi`,
the trace-free strain, stress, and acceleration are

.. math::

   S_{ij} = \frac12(\nabla_i u_j+\nabla_j u_i)
          -\frac13\delta_{ij}\nabla\cdot\mathbf u,\qquad
   \tau_{ij}=2\rho\nu_t S_{ij},\qquad
   \mathbf a_v=\rho^{-1}\nabla\cdot\boldsymbol\tau.

The radial limit is

.. math::

   U_q = \frac{1}{\rho r^3}\deriv{}{r}
       \left[\frac43\rho\nu_t r^3
       \left(\deriv{u_r}{r}-\frac{u_r}{r}\right)\right],\qquad
   E_q = \frac43\nu_t
       \left(\deriv{u_r}{r}-\frac{u_r}{r}\right)^2.

These are the radial momentum and energy transfer terms of the
Kuhfuss closure. About a static background, the viscous force is
first order but :math:`\delta E_q=0`. Coefficient perturbations
multiply the zero background strain and do not enter the linear
force. Viscous damping is included through momentum, without an
additional first-order heating term in the local TDC solve.

For nonradial modes write
:math:`\boldsymbol\xi=rs(y_1Y_{\ell m}\hat{\mathbf r}
+h\nabla_\Omega Y_{\ell m})`, where :math:`s=x^{\ell-2}`.
With :math:`L=\ell(\ell+1)`, define

.. math::

   n=\frac{\tau_{rr}}{\rho grs},\quad
   t=\frac{\tau_{rh}}{\rho grs},\quad
   F=\frac{{\rm i}\sigma\nu_t}{gr}.

The normal and tangential tractions satisfy

.. math::

   n=-F\left[\frac43\left(x\deriv{y_1}{x}+(\ell-2)y_1\right)
                     +\frac23Lh\right],\qquad
   t=-F\left[x\deriv{h}{x}+(\ell-2)h+y_1\right].

The force components are

.. math::

   \frac{a_{v,r}}{gs}=x\deriv{n}{x}+Kn-Lt,\qquad
   \frac{a_{v,h}}{gs}=x\deriv{t}{x}+Kt-\frac12n-F(2-L)h,

where :math:`K=U+\ell-A^*-V_g`. The traction normalization uses the
same constrained hydrostatic derivatives as GYRE's momentum rows.
Horizontal momentum becomes

.. math::

   x\deriv{t}{x}=y_2+\alpha_{\rm grv}y_3-c_1\omega^2h
                 -Kt+\frac12n+F(2-L)h.

The mechanical and thermal variables are transformed to
:math:`z_2=y_2-n` and :math:`z_5=y_5+C_\omega n`, where
:math:`C_\omega=V\nabla_{\rm ad}/f_{\rm rht}` and
:math:`f_{\rm rht}=1-\alpha_{\rm rht}c_{\rm thn}{\rm i}\omega/4`.
Continuity supplies the normal traction as a local algebraic relation.
These transformations remove its derivative from radial momentum
and the entropy-gradient equation. The entropy row retains
:math:`(xC_\omega'-C_\omega K)n+C_\omega Lt`. The derivative of
:math:`C_\omega` uses its endpoint values on the grid interval.
The equations above use the ``OSC`` convention. With ``EXP``, replace
:math:`\omega` by :math:`{\rm i}\omega_{\rm EXP}` throughout.
The transformations become the identity when viscosity vanishes.
The other four GYRE variables are unchanged. The radial
problem has six variables; the nonradial problem has eight.

The ``COLLOC_GL2`` viscous equations use second-order midpoint differences with
horizontal displacement at interval centers and tractions at grid
points. The tangential constitutive relation remains implicit and
sets :math:`t=0` where :math:`\nu_t=0`; it is not divided by viscosity.
In an inviscid interval, horizontal momentum reduces to

.. math::

   h=\frac{\overline{y_2}+\alpha_{\rm grv}\overline{y_3}}{c_1\omega^2},

where the bar denotes the midpoint average. Its discrete row is
divided by :math:`(\Delta x/x)c_1\omega^2`, giving :math:`h` a
coefficient of :math:`-1`. The inviscid surface relation uses the same
normalization. These nonzero analytic row scalings remove the
:math:`\omega^2` determinant factors introduced by retaining the
algebraic variables. They do not change the physical eigenvalues.
The differential horizontal-momentum rows in viscous intervals are
unchanged. As in the inviscid equations, :math:`\omega=0` is excluded.

For radial modes, ``MAGNUS_GL2`` applies the native midpoint Magnus
propagator to the six transformed equations. For nonradial modes write
the same differential rows as

.. math::

   xz'=Bz+bh+ct,\qquad xt'=az+\beta h+\gamma t,

where :math:`z` contains the six transformed variables, :math:`B` is
a matrix, :math:`b,c` are columns, and :math:`a` is a row. Define

.. math::

   \mathcal H z=\frac{z_2+\alpha_{\rm grv}z_3}{c_1\omega_{\rm OSC}^2},
   \qquad h_{\rm v}=h-\mathcal H z.

Here :math:`\mathcal H` is the row selecting the ordinary horizontal
response. Hold :math:`h_{\rm v}` and the background coefficients fixed at the interval
midpoint :math:`x_m`. The native Magnus block propagates

.. math::

   \frac{\diff}{\diff x}\begin{pmatrix}z\\h_{\rm v}\\t\end{pmatrix}
   =\frac{1}{x_m}
    \begin{pmatrix}B+b\mathcal H&b&c\\0&0&0\\a+\beta\mathcal H&\beta&\gamma\end{pmatrix}_m
    \begin{pmatrix}z\\h_{\rm v}\\t\end{pmatrix}.

Substitute :math:`h_{\rm v}=h_m-\mathcal H(z_a+z_b)/2` in the endpoint block.
The stored interval displacement :math:`h_m` and the implicit shear
constitutive relation are unchanged. This is a partitioned second order
method, not a nodal eight-variable Magnus discretization. The local
constant :math:`h_{\rm v}` is a numerical reconstruction, not a physical closure.

At zero viscosity, :math:`B+b\mathcal H` is the ordinary GYRE matrix and
:math:`a+\beta\mathcal H=0`. Zero traction gives :math:`h_{\rm v}=0`. These intervals
use the native six-variable Magnus block directly, with algebraic
horizontal displacement and zero-traction constraints. No viscosity
floor or division by viscosity is used. Positive-viscosity central
intervals retain the regular polynomial block for both schemes.

At a free viscous surface the boundary conditions are
:math:`z_2-y_1=0` and :math:`t=0`. The inner boundary has
zero radial displacement and zero tangential traction for ``ZERO_R``.
At a ``REGULAR`` center, ordinary central conditions and zero tangential
traction apply when the first interval is inviscid. A positive-viscosity
first interval instead uses regular scalar and spheroidal vector
expansions. With :math:`u=x/x_2`, where :math:`x_2` is the first positive
grid point, the nonradial expansion is

.. math::

   y_1=a_0+a_2u^2,\quad h=a_0/\ell+h_2u^2,\quad
   y_2=p_0+p_2u^2,\quad y_3=\phi_0+\phi_2u^2,

.. math::

   y_4=\ell\phi_0+g_2u^2,\quad y_5=s_2u^2,\quad y_6=f_0+f_2u^2.

The four central amplitudes are :math:`(a_0,p_0,\phi_0,f_0)`.
Seven equations at :math:`u=1/2` determine the seven remaining
coefficients. For radial modes use :math:`y_1=a_2u^2+a_4u^4`,
:math:`h=0`, :math:`y_4=g_2u^2`, :math:`y_5=s_2u^2`,
:math:`y_6=f_2u^2`, and the same forms for :math:`y_2,y_3`.
The retained amplitudes are :math:`(a_2,p_0,\phi_0)`; six midpoint
equations determine the other six coefficients. Stresses and their
derivatives follow from these polynomials and the local viscosity.
The first positive node matches to the ordinary staggered variables.
No finite central cutoff or viscosity floor is used. This central
collocation approximation requires a regular equilibrium and spatial
convergence of the first interval. The central viscosity must be finite
and positive, or the first interval must be inviscid. A coefficient that
vanishes only at the origin is not supported by this expansion.

For evolutionary models, the geometry uses :math:`r=\Rstar x` and
:math:`M_r=\Mstar x^3/c_1`, rather than interpolating the raw mass column.
The TDC background luminosities likewise retain their :math:`x^3`
factors. The horizontal diffusion coefficient is reconstructed from
the entropy diffusivity and the local :math:`r^{-2}` geometric factor.

At segment boundaries, match radial displacement,
:math:`U(z_2-y_1)`, potential, :math:`y_4+Uy_1`, Lagrangian temperature
:math:`y_5+V\nabla_{\rm ad}(y_2-y_1)`, and luminosity. If both sides
are viscous, match tangential displacement and :math:`Ut`.
If either side is inviscid, both tangential tractions vanish and
tangential slip is allowed.
The ordinary GYRE variables are recovered for output, while
:math:`\xi_h` at viscous points is interpolated from the solved interval
values. At inviscid points it uses the algebraic horizontal momentum
relation. Mode inertia uses this returned displacement. Native tractions
and interval-centered displacement are not saved in detail output.

The standard ``dW_dx`` is the thermal work expression and does not include
explicit viscous work. The separate ``P_visc`` output is the negative
phase-averaged volume dissipation in units of
:math:`G\Mstar^2/(\Rstar t_{\rm dyn})`, where
:math:`t_{\rm dyn}=(\Rstar^3/G\Mstar)^{1/2}`.
It uses native midpoint normal strains and the solved tangential traction,
and scales with the squared mode amplitude. ``P_visc_cum`` accumulates
this loss outward; ``dP_visc_dx`` is its interval average ending at the
indicated grid point. These fields do not include boundary power and
are zero when viscosity is disabled.

``P_visc_force`` is the phase-averaged contraction of velocity with the
native viscous acceleration. ``P_visc_bound`` is the work at the inner
and outer face of each segment, including both sides of an interface:

.. math::

   P_F=\frac12\Re\int\rho\,\mathbf v^*\cdot\mathbf a_\nu\,\diff V,
   \qquad
   B_\nu=\frac12\Re\sum_s\oint_{\partial V_s}
       \mathbf v^*\cdot\boldsymbol\tau\cdot\mathbf n_s\,\diff A.

The continuous identity is :math:`P_F=B_\nu+P_D`, where
:math:`P_D` is ``P_visc``. ``P_visc_residual`` reports
:math:`P_F-B_\nu-P_D` using independently evaluated terms. The force
contraction uses midpoint quadrature and differences of the nodal
stresses within each segment. The central interval uses its polynomial
derivatives. The finite-grid balance is not an exact summation by parts
identity; its residual must decrease with refinement. These are powers,
not dimensionless growth rates. Detail fields with ``_cum`` give
cumulative values. All use the units and normalization of ``P_visc``.
Positive-viscosity centers, density jumps, and this work balance still
require numerical convergence tests.

Differentiating point-sampled eigenfunctions across
a zero-viscosity boundary need not recover the staggered shear used by
the solver. A discrete viscous-work check requires the native stresses
and consistent quadrature.

The frequency search is independent of the matrix solver and spatial
discretization. Strongly nonadiabatic modes may lie far from the real
adiabatic frequencies. A :nml:option:`nad_search <num.nad_search>` of
:nml:value:`'CONTOUR'` supplies complex trial frequencies without a
previous run; :nml:value:`'FILE'` can instead read saved frequencies.
Changes in viscosity or spatial resolution require checks of mode
identity and convergence; the determinant ratio :math:`\chi` alone
does not provide those checks.

This treatment is distinct from :nml:option:`alpha_trb <osc.alpha_trb>`
below. The two prescriptions cannot be combined.

.. _osc-conv-turb:

Turbulent Damping
-----------------

The Reynolds number in stars is very large, and thus convection tends
to be turbulent. Following the treatment by
:ads_citet:`willems:2010`, GYRE can partially incorporate the
mechanical effects of this turbulence by adding a term

.. math::

   f_{r,{\rm visc}} = \frac{1}{r^{2}} \pderiv{}{r} \left( \rho \nu r^{2} \pderiv{v'_{r}}{r} \right)

to the radial component of the linearized momentum equation
(:eq:`e:osc-lin-mom`), representing the viscous force per unit volume
arising from radial fluid motions. Because this term depends on
:math:`v'_{r}`, it is phase-shifted by a quarter cycle relative to the
other terms in the equation, and acts like a drag force that damps
oscillations. The turbulent viscosity coefficient :math:`\nu` is
evaluated as

.. math::

   \nu = \frac{L^{2}}{\tconv}
   \left[ 1 + \left( \tconv \frac{\sigma}{2\pi} \right)^{\alphacon} \right]^{-1},

where :math:`L` is the mixing length, and :math:`\tconv` is the local
convection turnover timescale. The term in square brackets acts to
reduce the viscosity when the tidal forcing occurs at a rate faster
than the turnover timescale. As discussed by
:ads_citet:`willems:2010`, different authors have proposed different
exponents :math:`\alphacon`; GYRE's default :math:`\alphacon=1` can be
over-ridden using the :nml:option:`alpha_con` option.

GYRE evaluates the mixing length as

.. math::

   L = \alphatrb \min(H_{P}, r),

where :math:`H_{P}` is the local pressure scale height, and
:math:`\alphatrb` is implemented as a switch (see the
:ref:`osc-physics-switches` section). A reasonable choice is to set
:math:`\alphatrb` equal to the MLT mixing length parameter
:math:`\alpha_{\rm MLT}` of the stellar model. To disable turbulent
damping completely, set :math:`\alphatrb` to zero (the default).

To estimate the convection turnover timescale, GYRE uses the simple formula

.. math::

   \tconv = \left[ \max\left(-N^{2}, 0\right) \right]^{-1/2}.
