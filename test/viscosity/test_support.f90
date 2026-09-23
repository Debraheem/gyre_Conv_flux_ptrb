program test_support

   use forum_m, only: RD
   use gyre_m
   use tdc_visc_m

   implicit none (type, external)

   type(model_par_t) :: ml_p
   type(evol_model_t), target :: model
   class(model_t), pointer :: ml
   type(context_t), target :: context
   type(context_t), pointer :: cx
   type(osc_par_t) :: os_p
   type(mode_par_t) :: md_p
   type(num_par_t) :: nm_p
   type(rot_par_t) :: rt_p
   type(grid_t) :: gr
   type(nad_bvp_t) :: bp
   class(sysmtx_ct), allocatable :: sm
   type(state_ct) :: st
   type(ext_ct) :: det, ref
   type(tdc_visc_pt_t), allocatable :: vp(:)
   complex(RD), allocatable :: z(:,:)
   real(RD), allocatable :: power(:), power_ref(:)
   complex(RD) :: y(6), xi_h
   real(RD) :: x(257), err, x_min
   character(6), parameter :: solvers(3) = ['BANDED', 'ROWPP ', 'CYCLIC']
   character(64) :: arg
   integer :: i, l, it, ic, ir

   call init_math()
   call get_command_argument(1, ml_p%file)
   call get_command_argument(2, arg)
   ir = 0
   if (len_trim(arg) > 0) read(arg,*) ir
   ml_p%interp_type = 'LINEAR'
   model = mesa_model_t(ml_p)
   ml => model
   call get_command_argument(3, arg)
   x_min = 0.1_RD
   if (trim(arg) == 'regular') then
      gr = ml%grid()
      x_min = gr%pt(2)%x
   end if
   do i = 1, size(x)
      x(i) = exp(log(x_min)*(size(x)-i)/(size(x)-1))
   end do
   if (trim(arg) == 'regular') x(1) = 0._RD
   gr = grid_t(x)
   allocate(vp(gr%n), z(8,gr%n), power(gr%n), power_ref(gr%n))
   os_p%inner_bound = 'ZERO_R'
   if (trim(arg) == 'regular') os_p%inner_bound = 'REGULAR'
   call get_command_argument(4, arg)
   if (len_trim(arg) > 0) nm_p%diff_scheme = trim(arg)
   print *, 'Difference scheme: ', trim(nm_p%diff_scheme)
   os_p%outer_bound = 'VACUUM'
   os_p%tdc_alpha_M = 0.25_RD
   os_p%tdc_include_Pturb = .true.
   os_p%alpha_rht = real(ir,RD)
   do ic = 1, 2
      if (ic == 1) os_p%conv_scheme = 'FROZEN_PESNELL_4'
      if (ic == 2) os_p%conv_scheme = 'PERTURBED_TDC_LOCAL'
      os_p%alpha_hfc = real(ic-1,RD)
      do l = 0, 3
         md_p%l = l
         do it = 1, 2
            os_p%time_factor = 'OSC'
            st = state_ct(cmplx(3.1_RD,0.23_RD,kind=RD))
            if (it == 2) then
               os_p%time_factor = 'EXP'
               st = state_ct(cmplx(0.23_RD,-3.1_RD,kind=RD))
            end if
            context = context_t(ml, gr, md_p, os_p, rt_p)
            cx => context
            do i = 1, gr%n
               vp(i) = tdc_visc_pt_t(cx, gr%pt(i), os_p)
            end do
            z = 0._RD
            z(1:2,:) = 1._RD
            if (l > 0) z(7,:) = 1._RD
            call tdc_visc_transform(vp(1), st, z(:,1), z(7,1), y, xi_h)
            if (l == 0 .and. xi_h /= 0._RD) error stop 'radial horizontal displacement'
            call tdc_visc_work(cx, vp, gr, os_p, st, z(:merge(6,8,l == 0),:), power)
            if (any(power(2:) > power(:gr%n-1))) error stop 'positive viscous power'
            if (it == 1) power_ref = power
            if (maxval(abs(power-power_ref)) > 1.e-12_RD*max(1._RD,maxval(abs(power_ref)))) &
               error stop 'power time convention'
            if (l == 1 .and. maxval(abs(power)) > 1.e-20_RD) error stop 'translation dissipation'
            call tdc_visc_work(cx, vp, gr, os_p, st, 2._RD*z(:merge(6,8,l == 0),:), power)
            if (maxval(abs(power-4._RD*power_ref)) > 1.e-12_RD*max(1._RD,maxval(abs(power_ref)))) &
               error stop 'power amplitude scaling'
            do i = 1, size(solvers)
               nm_p%nad_matrix_solver = solvers(i)
               bp = nad_bvp_t(cx, gr, md_p, nm_p, os_p)
               sm = sysmtx_ct(bp, trim(solvers(i)))
               call bp%eval_det(sm, st, det)
               if (i == 1 .and. it == 1) ref = det
               err = abs(cmplx(det/ref)-1._RD)
               print *, trim(os_p%conv_scheme), l, trim(os_p%time_factor), trim(solvers(i)), err
               if (err > 1.e-8_RD) error stop 'determinant mismatch'
            end do
         end do
      end do
   end do
   print *, 'PASS: matrix solvers, time conventions, dissipative power and amplitude scaling'

end program test_support
