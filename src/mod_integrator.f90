! mod_integrator.f90
! Modul Integrator Numerik.
! Menggunakan metode Runge-Kutta orde 4 (RK4) untuk menyelesaikan persamaan diferensial.
! Metode ini sangat populer di NASA untuk simulasi orbit karena akurasinya.

module mod_integrator
    use mod_precision
    use mod_rocket
    use mod_physics
    implicit none
    
contains

    ! Melakukan satu langkah integrasi waktu (time step)
    subroutine rk4_step(t, dt, s, cfg, is_burning, s_next)
        real(wp), intent(in) :: t, dt
        type(RocketState), intent(in) :: s
        type(RocketConfig), intent(in) :: cfg
        logical, intent(in) :: is_burning
        type(RocketState), intent(out) :: s_next
        
        type(RocketState) :: k1, k2, k3, k4
        type(RocketState) :: temp_state
        
        ! Hitung k1
        k1 = get_derivatives(t, s, cfg, is_burning)
        
        ! Hitung k2
        temp_state = s + (k1 * (0.5_wp * dt))
        k2 = get_derivatives(t + 0.5_wp*dt, temp_state, cfg, is_burning)
        
        ! Hitung k3
        temp_state = s + (k2 * (0.5_wp * dt))
        k3 = get_derivatives(t + 0.5_wp*dt, temp_state, cfg, is_burning)
        
        ! Hitung k4
        temp_state = s + (k3 * dt)
        k4 = get_derivatives(t + dt, temp_state, cfg, is_burning)
        
        ! Gabungkan hasil (Weighted Average)
        ! s_next = s + (dt/6) * (k1 + 2*k2 + 2*k3 + k4)
        s_next = s + ((k1 + (k2 * 2.0_wp) + (k3 * 2.0_wp) + k4) * (dt / 6.0_wp))
        
    end subroutine rk4_step

end module mod_integrator
