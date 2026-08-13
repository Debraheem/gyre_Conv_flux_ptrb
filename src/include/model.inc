#! Include : model
#! Purpose : model-related macros
#!
#! Copyright 2013-2026 Rich Townsend & The GYRE Team
#!
#! This file is part of GYRE. GYRE is free software: you can
#! redistribute it and/or modify it under the terms of the GNU General
#! Public License as published by the Free Software Foundation, version 3.
#!
#! GYRE is distributed in the hope that it will be useful, but WITHOUT
#! ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#! or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
#! License for more details.
#!
#! You should have received a copy of the GNU General Public License
#! along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!!! Canonical coefficient names

#:set COEFF_NAMES = ('V_2', 'As', 'U', 'c_1', 'Gamma_1', 'ups_T', 'nabla_ad', &
   'nabla', 'beta_rad', 'c_lum', 'c_rad', 'c_thn', 'c_thk', 'c_eps', 'c_egv', &
    'eps_rho', 'eps_T', 'kap_rho', 'kap_T', 'Omega_rot', &
    'tdc_r', 'tdc_m', 'tdc_L_r', 'tdc_Peos', 'tdc_T', 'tdc_rho', 'tdc_kap', &
    'tdc_L_conv0', 'tdc_A0', 'tdc_D_h', 'tdc_c_hfc', 'tdc_Hp', 'tdc_alpha_mlt', &
    'tdc_Cp', 'tdc_chiT', 'tdc_chiRho', 'tdc_gradL', 'tdc_gradT', &
    'tdc_alpha_C', 'tdc_alpha_S', 'tdc_alpha_D', 'tdc_alpha_R', 'tdc_alpha_Pt', &
    'tdc_alpha_M', 'tdc_include_mlt_corr', 'tdc_mlt_Pturb_factor', 'tdc_mlt_Pturb0')

#!!! Canonical coefficient index names

#:set COEFF_IDX_NAMES = ['I_{:s}'.format(name.upper()) for name in COEFF_NAMES]
