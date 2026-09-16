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
of the isotropic convective heat-flux perturbation. The closure is

.. math::

   \delta \vF_{{\rm conv},h} = - \rho T D_{{\rm conv},h} \nabla_h \delta S,

This contributes :math:`-\alphahfc \lambda \chfc y_5` to the :math:`y_6`
equation. It vanishes for radial modes. The :nml:option:`alpha_hfc
<osc.alpha_hfc>` option scales the term.

The horizontal term can be used with either frozen-convection scheme. With
:nml:option:`conv_scheme <osc.conv_scheme>` set to
:nml:value:`'PERTURBED_TDC_LOCAL'`, GYRE also evaluates the radial convective
luminosity perturbation and the TDC velocity equation. In this case :math:`y_6`
represents the total luminosity perturbation, and a local two-by-two system
determines :math:`\delta\nabla` and :math:`\delta A`.

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

When :nml:option:`tdc_perturb_mlt_Pturb <osc.tdc_perturb_mlt_Pturb>` is
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

The local linearization holds :math:`c_P`, :math:`H_P`,
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

The current local TDC branch cannot be combined with
:nml:option:`alpha_trb <osc.alpha_trb>` or with inhomogeneous forcing. GYRE
stops with an error for either combination.

The standard MESA structure coefficients in the model continue to use
:math:`P_{\rm eos}`. The local turbulent-pressure option changes the pressure
perturbation split, but it does not reconstruct background hydrostatic
coefficients or the outer pressure boundary condition using
:math:`P_{\rm tot}`.

The local TDC equations do not use the exported ``tdc_alpha_M`` coefficient
to compute eddy viscosity, for either radial or nonradial modes. They also
omit the optional turbulent-energy storage term included by MESA when
``TDC_include_eturb_in_energy_equation`` and
``star_LNA_perturb_turbulent_energy`` are enabled. In the continuous limit,
:math:`e_{\rm turb}=A^2` and :math:`\delta e_{\rm turb}=2A_0\delta A`.

Harmonic mixing-length support is deferred. Current matched MESA comparisons
require ``harmonic_dissipation_length_beta = 0`` and use
:math:`\Lambda=\alpha_{\rm MLT}H_P`.

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
