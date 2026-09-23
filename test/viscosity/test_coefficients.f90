program test_coefficients

   use forum_m, only: RD
   use gyre_m
   use tdc_visc_m
   use gyre_nad_diff_eqns_m
   use magnus_gl2_block_m
   use diff_eqns_m

   implicit none (type, external)

   type(model_par_t) :: ml_p
   type(evol_model_t), target :: model
   class(model_t), pointer :: ml
   type(context_t), target :: context
   type(context_t), pointer :: cx
   type(osc_par_t) :: os_p
   type(mode_par_t) :: md_p
   type(rot_par_t) :: rt_p
   type(grid_t) :: gr
   type(point_t) :: pt
   type(tdc_visc_pt_t) :: vp
   type(tdc_visc_block_t) :: block
   type(gyre_nad_diff_eqns_t) :: de
   type(magnus_gl2_block_ct) :: magnus
   type(ext_ct) :: scl
   type(state_ct) :: st
   real(RD) :: c, imported, alpha, V, V_g, ups_T, C_T, x, d
   complex(RD) :: z(8), y(6), h, xi_h, F, normal
   complex(RD) :: E(8,16), E_t(16,8), B(6,6), reduced(6,12), expected(6,12)
   complex(RD), parameter :: omega(3) = [(0.3_RD,0.02_RD), (0.37_RD,-0.1_RD), (1.2_RD,0.3_RD)]
   character(10), parameter :: schemes(2) = ['COLLOC_GL2','MAGNUS_GL2']
   integer :: j, k, l, k_inv, i, i_w, i_scheme

   call init_math()
   call get_command_argument(1, ml_p%file)
   ml_p%interp_type = 'LINEAR'
   model = mesa_model_t(ml_p)
   ml => model
   gr = ml%grid()
   k = 0
   do j = 1, gr%n
      pt = gr%pt(j)
      if (tdc_visc_coeff(ml, pt, 0._RD) /= 0._RD) error stop 'default viscosity'
      c = tdc_visc_coeff(ml, pt, 0.15_RD)
      alpha = ml%coeff(I_TDC_ALPHA_M, pt)
      imported = tdc_visc_coeff(ml, pt, -1._RD)
      if (abs(imported-c*alpha/0.15_RD) > 1.e-13_RD*max(c, tiny(c))) error stop 'profile coefficient'
      if (abs(tdc_visc_coeff(ml, pt, 0.3_RD)-2._RD*c) > 1.e-13_RD*max(c, tiny(c))) &
         error stop 'coefficient override'
      if (ml%coeff(I_TDC_A0, pt) == 0._RD .and. c /= 0._RD) error stop 'zero velocity'
      if (c > 0._RD .and. pt%x < 0.9_RD) k = j
   end do
   if (k == 0) error stop 'no viscous test point'

   pt = gr%pt(k)
   x = pt%x
   c = tdc_visc_coeff(ml, pt, 0.15_RD)
   V = ml%coeff(I_V_2, pt)*x*x
   V_g = V/ml%coeff(I_GAMMA_1, pt)
   ups_T = ml%coeff(I_UPS_T, pt)
   C_T = V*ml%coeff(I_NABLA_AD, pt)
   os_p%conv_scheme = 'FROZEN_PESNELL_4'
   os_p%tdc_alpha_M = 0.15_RD
   st = state_ct(cmplx(2._RD,0.3_RD,kind=RD))
   F = cmplx(0._RD,1._RD,kind=RD)*st%omega*c
   do j = 1, 8
      z(j) = cmplx(0.13_RD*j,-0.07_RD*j,kind=RD)
   end do
   do l = 0, 3
      md_p%l = l
      context = context_t(ml, gr, md_p, os_p, rt_p)
      cx => context
      vp = tdc_visc_pt_t(cx, pt, os_p)
      h = z(7)
      if (l == 0) h = 0._RD
      call tdc_visc_transform(vp, st, z, h, y, xi_h)
      normal = -F*((4._RD/3._RD)*((V_g-3._RD)*y(1)-V_g*y(2)+ups_T*y(5)) &
         +2._RD*l*(l+1)*h)
      if (abs(y(2)-z(2)-normal) > 1.e-11_RD*max(1._RD,abs(normal))) error stop 'normal traction'
      if (abs(y(5)+C_T*(y(2)-z(2))-z(5)) > 1.e-11_RD) error stop 'entropy transformation'
      if (abs(xi_h-h*x**(l-1)) > 1.e-11_RD) error stop 'horizontal displacement'
   end do
   print *, 'PASS: coefficient selection, zero velocity, radial and nonradial transformations'

   k_inv = 0
   do j = 2, gr%n-2
      pt = gr%pt(j)
      pt%x = (pt%x+gr%pt(j+1)%x)/2._RD
      if (tdc_visc_coeff(ml, pt, 0.15_RD) == 0._RD) then
         k_inv = j
         exit
      end if
   end do
   if (k_inv == 0) error stop 'no inviscid test interval'
   d = (gr%pt(k_inv+1)%x-gr%pt(k_inv)%x)/pt%x
   do i_scheme = 1, size(schemes)
      do l = 1, 3
         md_p%l = l
         context = context_t(ml, gr, md_p, os_p, rt_p)
         cx => context
         block = tdc_visc_block_t(cx, gr, k_inv, os_p, schemes(i_scheme))
         de = gyre_nad_diff_eqns_t(cx, pt, os_p)
         magnus = magnus_gl2_block_ct(diff_eqns_factory, gr%pt(k_inv), gr%pt(k_inv+1))
         do i_w = 1, size(omega)
            st = state_ct(omega(i_w))
            call block%eval(st, E, scl)
            if (abs(E(7,7)+1._RD) > 1.e-14_RD) error stop 'inviscid horizontal pivot'
            if (i_scheme == 1 .and. scl /= ONE_CT) error stop 'inviscid determinant scale'
            call block%eval(st, E_t, scl, trans=.true.)
            if (maxval(abs(E_t-transpose(E))) > 1.e-14_RD*maxval(abs(E))) error stop 'block transpose'
            call de%eval(st, pt%x, B)
            expected(:,:6) = 0.5_RD*d*B
            expected(:,7:) = expected(:,:6)
            do i = 1, 6
               expected(i,i) = expected(i,i)+1._RD
               expected(i,i+6) = expected(i,i+6)-1._RD
               reduced(:,i) = E(:6,i)+E(:6,7)*E(7,i)
               reduced(:,i+6) = E(:6,i+8)+E(:6,7)*E(7,i+8)
            end do
            if (i_scheme == 2) then
               call magnus%eval(st, expected, scl)
               expected = -expected
            end if
            if (maxval(abs(reduced-expected)) > 1.e-12_RD*maxval(abs(expected))) &
               error stop 'inviscid six-variable reduction'
         end do
         if (tdc_visc_coeff(ml, gr%pt(gr%n), 0.15_RD) == 0._RD) then
            block = tdc_visc_block_t(cx, gr, gr%n-1, os_p, schemes(i_scheme))
            do i_w = 1, size(omega)
               st = state_ct(omega(i_w))
               call block%eval(st, E, scl)
               if (E(8,15) /= -1._RD) error stop 'inviscid surface pivot'
               c = ml%coeff(I_C_1, gr%pt(gr%n))
               if (abs(E(8,10)*c*st%omega**2-1._RD) > 1.e-14_RD) error stop 'inviscid surface pressure'
            end do
         end if
      end do
      print *, 'PASS: inviscid horizontal pivots and six-variable reduction ', schemes(i_scheme)
   end do

   ! Approach zero viscosity at a convective point, without a coefficient floor.

   os_p%tdc_alpha_M = 1.e-12_RD
   pt = gr%pt(k)
   pt%x = (pt%x+gr%pt(k+1)%x)/2._RD
   do l = 1, 3
      md_p%l = l
      context = context_t(ml, gr, md_p, os_p, rt_p)
      cx => context
      block = tdc_visc_block_t(cx, gr, k, os_p, 'MAGNUS_GL2')
      magnus = magnus_gl2_block_ct(diff_eqns_factory, gr%pt(k), gr%pt(k+1))
      do i_w = 1, size(omega)
         st = state_ct(omega(i_w))
         call block%eval(st, E, scl)
         call magnus%eval(st, expected, scl)
         expected = -expected
         do i = 1, 6
            reduced(:,i) = E(:6,i)-E(:6,7)*E(7,i)/E(7,7)
            reduced(:,i+6) = E(:6,i+8)-E(:6,7)*E(7,i+8)/E(7,7)
         end do
         if (maxval(abs(reduced-expected)) > 1.e-9_RD*maxval(abs(expected))) &
            error stop 'small-viscosity Magnus limit'
      end do
   end do
   print *, 'PASS: small positive viscosity limit'

contains

   subroutine diff_eqns_factory(pt, de)

      type(point_t), intent(in) :: pt(:)
      class(diff_eqns_ct), allocatable, intent(out) :: de(:)

      de = gyre_nad_diff_eqns_t(cx, pt, os_p)

   end subroutine diff_eqns_factory

end program test_coefficients
