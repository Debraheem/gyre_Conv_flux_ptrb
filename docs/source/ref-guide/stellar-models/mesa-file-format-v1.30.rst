Version 1.30
------------

Version-1.30 MESA-format files extend version 1.20 by appending
background time-dependent-convection (TDC) quantities exported by MESA.
These quantities are model data only; perturbed convection equations are
assembled by GYRE.

For these TDC quantities, use either linear interpolation or cubic
interpolation with monotonic derivatives.

The first line of version-1.30 MESA-format files is a header with the following columns:

.. list-table::
   :widths: 10 10 10 70
   :header-rows: 1

   * - Column
     - Symbol
     - Datatype
     - Definition
   * - 1
     - :math:`N`
     - integer
     - number of grid points
   * - 2
     - :math:`\Mstar`
     - real
     - stellar mass [:math:`\gram`]
   * - 3
     - :math:`\Rstar`
     - real
     - photospheric radius [:math:`\cm`]
   * - 4
     - :math:`\Lstar`
     - real
     - photospheric luminosity [:math:`\erg\,\second^{-1}`]
   * - 5
     - 130
     - integer
     - version number

The subsequent :math:`N` lines contain the model data, one line per
grid point extending from the center to the surface. Columns 1--20 are
identical to version 1.20. Columns 21--39 contain the TDC background
block:

.. list-table::
   :widths: 10 20 10 60
   :header-rows: 1

   * - Column
     - Symbol
     - Datatype
     - Definition
   * - 1
     - :math:`k`
     - integer
     - grid point index (:math:`k=1,\ldots,N`)
   * - 2
     - :math:`r`
     - real
     - radial coordinate [:math:`\cm`]
   * - 3
     - :math:`M_{r}`
     - real
     - interior mass [:math:`\gram`]
   * - 4
     - :math:`L_{r}`
     - real
     - interior luminosity [:math:`\erg\,\second^{-1}`]
   * - 5
     - :math:`P_{\rm eos}`
     - real
     - equation-of-state pressure, :math:`P_{\rm gas}+P_{\rm rad}`
       [:math:`\barye`]
   * - 6
     - :math:`T`
     - real
     - temperature [:math:`\kelvin`]
   * - 7
     - :math:`\rho`
     - real
     - density [:math:`\gram\,\cm^{-3}`]
   * - 8
     - :math:`\nabla`
     - real
     - dimensionless temperature gradient
   * - 9
     - :math:`N^{2}`
     - real
     - Brunt-Vaisala frequency squared [:math:`\second^{-2}`]
   * - 10
     - :math:`\Gamma_{1}`
     - real
     - adiabatic exponent
   * - 11
     - :math:`\nabla_{\rm ad}`
     - real
     - adiabatic temperature gradient
   * - 12
     - :math:`\upsT`
     - real
     - thermodynamic coefficient
   * - 13
     - :math:`\kappa`
     - real
     - opacity [:math:`\cm^{2}\,\gram^{-1}`]
   * - 14
     - :math:`\kappa\,\kapT`
     - real
     - opacity partial [:math:`\cm^{2}\,\gram^{-1}`]
   * - 15
     - :math:`\kappa\,\kaprho`
     - real
     - opacity partial [:math:`\cm^{2}\,\gram^{-1}`]
   * - 16
     - :math:`\epsnuc`
     - real
     - nuclear energy generation rate [:math:`\erg\,\second^{-1}\,\gram^{-1}`]
   * - 17
     - :math:`\epsnuc\,\epsnucT`
     - real
     - nuclear energy generation partial [:math:`\erg\,\second^{-1}\,\gram^{-1}`]
   * - 18
     - :math:`\epsnuc\,\epsnucrho`
     - real
     - nuclear energy generation partial [:math:`\erg\,\second^{-1}\,\gram^{-1}`]
   * - 19
     - :math:`\epsgrav`
     - real
     - gravothermal energy release rate [:math:`\erg\,\second^{-1}\,\gram^{-1}`]
   * - 20
     - :math:`\Orot`
     - real
     - rotation angular frequency [:math:`\radian\,\second^{-1}`]
   * - 21
     - :math:`L_{\rm conv,0}`
     - real
     - background radial convective luminosity [:math:`\erg\,\second^{-1}`]
   * - 22
     - :math:`A_{0}`
     - real
     - background TDC velocity variable, :math:`v_{\rm conv}/\sqrt{2/3}`
       [:math:`\cm\,\second^{-1}`]
   * - 23
     - :math:`D_{\rm conv,h}`
     - real
     - horizontal convective thermal diffusivity inferred from the radial TDC
       enthalpy flux [:math:`\cm^{2}\,\second^{-1}`]
   * - 24
     - :math:`H_{P}`
     - real
     - pressure scale height at the MESA face [:math:`\cm`]
   * - 25
     - :math:`\alpha_{\rm MLT}`
     - real
     - local dimensionless mixing-length parameter
   * - 26
     - :math:`c_{P}`
     - real
     - specific heat at constant pressure [:math:`\erg\,\gram^{-1}\,\kelvin^{-1}`]
   * - 27
     - :math:`\chi_{T}`
     - real
     - equation-of-state temperature derivative
   * - 28
     - :math:`\chi_{\rho}`
     - real
     - equation-of-state density derivative
   * - 29
     - :math:`\nabla_{\rm L}`
     - real
     - Ledoux gradient at the MESA face
   * - 30
     - :math:`\nabla_{T}`
     - real
     - MESA temperature gradient at the face
   * - 31
     - :math:`\alpha_{C}`
     - real
     - TDC convective-flux coefficient
   * - 32
     - :math:`\alpha_{S}`
     - real
     - TDC source coefficient
   * - 33
     - :math:`\alpha_{D}`
     - real
     - TDC turbulent damping coefficient
   * - 34
     - :math:`\alpha_{R}`
     - real
     - TDC radiative damping coefficient
   * - 35
     - :math:`\alpha_{P{\rm t}}`
     - real
     - TDC turbulent-pressure inertia coefficient
   * - 36
     - :math:`\alpha_{M}`
     - real
     - TDC eddy-viscosity coefficient; not used by the local heat-flux or
       turbulent-pressure closures
   * - 37
     - ---
     - real
     - MLT correction flag; 1 if MESA used ``include_mlt_corr_to_TDC`` and 0
       otherwise
   * - 38
     - :math:`f_{\rm Pt}`
     - real
     - MESA ``mlt_Pturb_factor`` used to scale the isotropic MLT turbulent
       pressure
   * - 39
     - :math:`P_{{\rm turb},0}`
     - real
     - background MLT/Kuhfuss turbulent pressure
       :math:`f_{\rm Pt}\rho v_{\rm conv}^{2}/3` [:math:`\barye`]

The TDC alpha coefficients, MLT correction flag, and ``mlt_Pturb_factor`` are
mode-independent model metadata. They are repeated in each row because the
plain-text MESA-format profile does not have an extensible metadata block. The
perturbed convective flux itself is not stored in the file; GYRE constructs it
from these background quantities, the mode frequency, and the eigenfunctions.

The turbulent-pressure columns follow the same local Kuhfuss/MLT convention as
MESA's radial LNA machinery. With :math:`A=v_{\rm conv}/\sqrt{2/3}`,

.. math::

   P_{{\rm turb},0} = f_{\rm Pt}\rho v_{\rm conv}^{2}/3
   = f_{\rm Pt}\rho (2/3)A_{0}^{2}/3.

When the perturbed local TDC closure is solved for :math:`\delta A`, the
corresponding isotropic turbulent-pressure perturbation is

.. math::

   \frac{\delta P_{\rm turb}}{P_{\rm eos}}
   = \frac{P_{{\rm turb},0}}{P_{\rm eos}}
     \left(\frac{\delta\rho}{\rho} + 2\frac{\delta A}{A_{0}}\right).

This is the pressure perturbation implied by the Kuhfuss local turbulent
pressure. It is separate from the :math:`\alpha_{P{\rm t}}` term, which enters
the TDC velocity equation as a turbulent-pressure inertia/work correction.
