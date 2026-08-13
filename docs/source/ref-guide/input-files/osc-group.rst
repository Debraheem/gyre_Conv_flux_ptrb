.. _osc-group:

.. nml:group:: osc

Osc Namelist Group
==================

The :nml:group:`osc` namelist group controls the treatment of the stellar
oscillation equations. The input file can contain one or more, but
only the last (tag-matching) one is used. The following options are
available:

.. nml:option:: inner_bound
   :type: string
   :default: 'REGULAR'

   Inner boundary conditions; one of

   - :nml:value:`'REGULAR'` : Regularity-enforcing\ [#inner-zero]_
   - :nml:value:`'ZERO_R'` : Zero radial displacement\ [#inner-nonzero]_
   - :nml:value:`'ZERO_H'` : Zero horizontal displacement\ [#inner-nonzero]_

.. nml:option:: outer_bound
   :type: string
   :default: 'VACUUM'

   Outer boundary conditions; one of

   - :nml:value:`'VACUUM'` : Vanishing surface density
   - :nml:value:`'ZERO_R'` : Zero radial displacement
   - :nml:value:`'ZERO_H'` : Zero horizontal displacement
   - :nml:value:`'DZIEM'` : Formulation following :ads_citet:`dziembowski:1971`
   - :nml:value:`'UNNO'` : Formulation following :ads_citet:`unno:1989`
   - :nml:value:`'JCD'` : Formulation following Jørgen Christensen-Dalsgaard (ADIPLS)
   - :nml:value:`'ISOTHERMAL'` : Formulation based on local dispersion analysis for isothermal atmosphere
   - :nml:value:`'GAMMA1'` : Vanishing displacement and derivative at outer boundary, intended for use with :math:`\gamma` modes (isolated g modes; see :ads_citealp:`ong:2020`)
   - :nml:value:`'GAMMA2'` : Variant of :nml:value:`'GAMMA1'` option described in :git:`PR #8 <rhdtownsend/gyre/pull/8>`

.. nml:option:: outer_bound_cutoff
   :type: string
   :default: ''

   Outer boundary conditions to use when evaluating cutoff frequencies
   (see :nml:option:`freq_units <scan.freq_units>`); same options as
   :nml:option:`outer_bound`, and if left blank then takes its value
   from :nml:option:`outer_bound`

.. nml:option:: outer_bound_branch
   :type: string
   :default: 'E_NEG'

   Dispersion relation solution branch to use for outer boundary
   conditions; one of

   - :nml:value:`'E_NEG'` : Outward-decaying energy density
   - :nml:value:`'E_POS'` : Outward-growing energy density
   - :nml:value:`'F_NEG'` : Outward energy flux
   - :nml:value:`'F_POS'` : Inward energy flux
   - :nml:value:`'V_NEG'` : Outward phase velocity
   - :nml:value:`'V_POS'` : Inward phase velocity

   Used only when :nml:option:`outer_bound` = :nml:valuelist:`'UNNO'
   'JCD' 'ISOTHERMAL'`

.. nml:option:: variables_set
   :type: string
   :default: 'GYRE'

   Dependent variables in oscillation equations; one of

   - :nml:value:`'GYRE'` : GYRE formulation, as described in the :ref:`osc-dimless-form` section
   - :nml:value:`'DZIEM'` : Formulation following :ads_citet:`dziembowski:1971`
   - :nml:value:`'JCD'` : Formulation following Jørgen Christensen-Dalsgaard (ADIPLS)
   - :nml:value:`'MIX'` : Mixed formulation (:nml:value:`'JCD'` for :math:`y_{3,4}`, :nml:value:`'DZIEM'` for :math:`y_{1,2}`)
   - :nml:value:`'LAGP'` : Lagrangian pressure perturbation formulation

.. nml:option:: lambda_method
   :type: string
   :default: 'SPH'

   Method adopted to evaluate the angular eigenvalue :math:`\lambda`;
   one of

   - :nml:value:`'SPH'` : Use the spherical-harmonic value :math:`\lambda=\ell(\ell+1)`
   - :nml:value:`'TAR-GRAVITY'` : Use the traditional approximation of rotation, for gravito-acoustic modes
   - :nml:value:`'TAR-ROSSBY'` : Use the traditional approximation of rotation, for Rossby modes
   - :nml:value:`'ADHOC` : Use an ad-hoc value set by the :nml:option:`lambda` option

.. nml:option:: lambda
   :type: real
   :default: 0

   Value of angular eigenvalue :math:`\lambda`. Used only when
   :nml:option:`lambda_method` = :nml:value:`'ADHOC'`

.. nml:option:: complex_lambda
   :type: logical
   :default: .FALSE.

   Use complex arithmetic when evaluating the angular angular
   eigenvalue :math:`\lambda`. Used only when
   :nml:option:`lambda_method` = :nml:valuelist:`'TAR-GRAVITY'
   'TAR-ROSSBY'`

.. nml:option:: alpha_grv
   :type: real
   :default: 1

   Scaling factor for gravitational potential perturbations (see the
   :math:`\alphagrv` entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_gbc
   :type: real
   :default: 1

   Scaling factor for the displacement term in the outer gravitational
   potential boundary condition (see the :math:`\alphagbc` entry in
   the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_thm
   :type: real
   :default: 1

   Scaling factor for the thermal timescale (see the :math:`\alphathm`
   entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_hfl
   :type: real
   :default: 1

   Scaling factor for horizontal flux perturbations (see the :math:`\alphahfl`
   entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_hfc
   :type: real
   :default: 0

   Scaling factor for horizontal convective heat-flux perturbations (see the
   :math:`\alphahfc` entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_gam
   :type: real
   :default: 1

   Scaling factor for g-mode isolation (see the :math:`\alphagam` term in
   entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_pi
   :type: real
   :default: 1

   Scaling factor for p-mode isolation (see the :math:`\alphapi` term in
   entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_kar
   :type: real
   :default: 1

   Scaling factor for opacity density partial derivative (see the :math:`\alphakar`
   entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_kat
   :type: real
   :default: 1

   Scaling factor for opacity temperature partial derivative (see the :math:`\alphakat`
   entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_rht
   :type: real
   :default: 0

   Scaling factor for time-dependent term in radiative heat equation (see the
   :math:`\alpharht` entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_trb
   :type: real
   :default: 0

   Scaling factor for the turbulent mixing length (see the
   :math:`\alphatrb` entry in the :ref:`osc-physics-switches` section)

.. nml:option:: alpha_con
   :type: real
   :default: 1

   Exponent in the turbulent viscosity reduction factor (see the
   :math:`\alphacon` entry in the :ref:`osc-physics-switches` section)

.. nml:option:: inertia_norm
   :type: string
   :default: 'BOTH'

   Inertia normalization factor; one of

   - :nml:value:`'RADIAL'` : Radial amplitude squared, :math:`|\xi_{\rm r}|^{2}`, evaluated at :nml:option:`x_ref`
   - :nml:value:`'HORIZ'` : Horizontal amplitude squared, :math:`|\lambda| |\xi_{\rm h}|^{2}`, evaluated at :nml:option:`x_ref`
   - :nml:value:`'BOTH'` : Overall amplitude squared, :math:`|\xi_{\rm r}|^{2} + |\lambda| |\xi_{\rm h}|^{2}`, evaluated at :nml:option:`x_ref`

.. nml:option:: time_factor
   :type: string
   :default: 'OSC'

   Time-dependence factor in pulsation equations; one of

   - :nml:value:`'OSC'` : Oscillatory, :math:`\propto \exp(-{\rm i} \sigma t)`
   - :nml:value:`'EXP'` : Exponential, :math:`\propto \exp(-\sigma t)`

.. nml:option:: conv_scheme
   :type: string
   :default: 'FROZEN_PESNELL_1'

   Scheme for treating convection; one of

   - :nml:value:`'FROZEN_PESNELL_1'` : Freeze convective heating altogether;
     case 1 described by :ads_citet:`pesnell:1990`
   - :nml:value:`'FROZEN_PESNELL_4'` : Freeze Lagrangian perturbation of convective luminosity;
     case 4 described by :ads_citet:`pesnell:1990`
   - :nml:value:`'PERTURBED_TDC_LOCAL'` : Evaluate the local TDC luminosity and
     velocity equations from a version-1.30 MESA-format model. The local
     algebraic system determines :math:`\delta\nabla` and :math:`\delta A` and
     replaces the radiative thermal-gradient closure. Set
     :nml:option:`alpha_hfc <osc.alpha_hfc>` to 1 to include the horizontal
     convective heat-flux term for nonradial modes. Set
     :nml:option:`tdc_perturb_mlt_Pturb <osc.tdc_perturb_mlt_Pturb>` to
     :nml:value:`.TRUE.` to include the local MLT turbulent-pressure
     perturbation. This scheme requires :nml:option:`variables_set
     <osc.variables_set>` = :nml:value:`'GYRE'` and does not support
     :nml:option:`alpha_trb <osc.alpha_trb>` > 0 or inhomogeneous forcing.

.. nml:option:: tdc_yenv_scheme
   :type: string
   :default: 'BACKGROUND_RATIO'

   Scheme for reconstructing the effective TDC superadiabaticity
   :math:`Y_{\rm env}` from a schema-130 MESA profile; one of

   - :nml:value:`'BACKGROUND_RATIO'` : Infer :math:`Y_{\rm env}` from the
     exported background convective luminosity.
   - :nml:value:`'NONE'` : Use :math:`Y_{\rm env}=Y`.

.. nml:option:: tdc_perturb_mlt_Pturb
   :type: logical
   :default: .FALSE.

   Include the local MLT turbulent-pressure perturbation in the
   :nml:value:`'PERTURBED_TDC_LOCAL'` convection branch. The turbulent-pressure
   amplitude is read from the version-1.30 ``tdc_mlt_Pturb0`` model
   coefficient. When this option is :nml:value:`.TRUE.` and
   ``tdc_mlt_Pturb0`` is nonzero at a mesh point, the local TDC closure uses a
   three-by-three solve for the EOS-pressure perturbation,
   :math:`\delta\nabla`, and :math:`\delta A`. Otherwise it uses the default
   two-by-two solve for :math:`\delta\nabla` and :math:`\delta A`.

.. nml:option:: deps_scheme
   :type: string
   :default: 'MODEL'

   Scheme for calculating nuclear energy generation partials
   :math:`\epsnucrho` and :math:`\epsnucT`; one of

   - :nml:value:`'MODEL'` : Use values from model
   - :nml:value:`'FILE'` : Use complex (phase-lagged) values from separate file

.. nml:option:: deps_file
   :type: string
   :default: ''

   Name of epsilon partial derivatives file. Used only when
   :nml:option:`deps_scheme` = :nml:value:`'FILE'`

.. nml:option:: deps_file_format
   :type: string
   :default: 'WOLF'

   Format of epsilon partial derivative file; one of

   - :nml:value:`'WOLF'` : Format used in preparation of :ads_citet:`wolf:2018`

   Used only when :nml:option:`deps_scheme` = :nml:value:`'FILE'`

.. nml:option:: x_ref
   :type: real
   :default: min(1, x_o)

   Reference fractional radius for photosphere, normalizations etc.

.. nml:option:: x_atm
   :type: real
   :default: -1

   Fractional radius for convection-zone crossover point of
   :math:`\pi/\gamma` modes (isolated p and g modes; see
   :ads_citealp:`ong:2020`)

.. nml:option:: adiabatic
   :type: logical
   :default: .TRUE.

   Perform adiabatic calculations

.. nml:option:: nonadiabatic
   :type: logical
   :default: .FALSE.

   Perform non-adiabatic calculations

.. nml:option:: quasiad_eigfuncs
   :type: logical
   :default: .FALSE.

   Calculate quasi-adiabatic entropy/luminosity eigenfunctions during
   adiabatic calculations

.. nml:option:: reduce_order
   :type: logical
   :default: .TRUE.

   Reduce the order of the *adiabatic* radial-pulsation equations from
   4 to 2

.. nml:option:: tag_list
   :type: string
   :default: ''

   Comma-separated list of :nml:option:`tag <mode.tag>` values to
   match; matches all if left blank

.. rubric:: Footnotes

.. [#inner-zero] Valid only when the inner calculation grid point is at :math:`x = 0`

.. [#inner-nonzero] Valid only when the inner calculation grid point is at :math:`x \ne 0`
