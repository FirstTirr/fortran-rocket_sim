! mod_physics.f90
! Modul Fisika: Menghitung gaya-gaya yang bekerja pada roket.
! Ini adalah "otak" dari simulasi.

module mod_physics
    use mod_precision
    use mod_constants
    use mod_atmosphere
    use mod_rocket
    implicit none
    
contains

    ! Menghitung turunan dari state vector (dy/dt)
    ! Input: t (waktu), s (state saat ini), cfg (konfigurasi roket)
    ! Output: ds (perubahan state)
    function get_derivatives(t, s, cfg, is_burning) result(ds)
        real(wp), intent(in) :: t
        type(RocketState), intent(in) :: s
        type(RocketConfig), intent(in) :: cfg
        logical, intent(in) :: is_burning
        type(RocketState) :: ds
        
        real(wp) :: r_mag, v_mag, altitude, rho
        real(wp) :: drag_force_mag, thrust_force_mag
        real(wp) :: mass_flow_rate
        real(wp) :: r_unit(3), v_unit(3), thrust_dir(3)
        real(wp) :: F_gravity(3), F_drag(3), F_thrust(3), F_total(3)
        
        ! 1. Hitung vektor posisi dan ketinggian
        r_mag = norm2(s%r)
        altitude = r_mag - R_EARTH
        r_unit = s%r / r_mag
        
        ! 2. Hitung vektor kecepatan
        v_mag = norm2(s%v)
        if (v_mag > 0.0_wp) then
            v_unit = s%v / v_mag
        else
            v_unit = [0.0_wp, 0.0_wp, 1.0_wp] ! Arah default jika diam
        end if
        
        ! --- GAYA GRAVITASI ---
        ! F = -G * M * m / r^2
        F_gravity = -(G * M_EARTH * s%mass) / (r_mag**2) * r_unit
        
        ! --- GAYA HAMBATAN UDARA (DRAG) ---
        ! F = -0.5 * rho * v^2 * Cd * A
        rho = get_air_density(altitude)
        drag_force_mag = 0.5_wp * rho * (v_mag**2) * cfg%drag_coeff * cfg%area
        F_drag = -drag_force_mag * v_unit
        
        ! --- GAYA DORONG (THRUST) ---
        F_thrust = [0.0_wp, 0.0_wp, 0.0_wp]
        mass_flow_rate = 0.0_wp
        
        if (is_burning .and. s%mass > cfg%dry_mass) then
            thrust_force_mag = cfg%thrust
            
            ! GUIDANCE LAW (Sistem Kendali Sederhana)
            ! 1. Vertical Ascent (t < 10s): Terbang lurus ke atas (searah r)
            ! 2. Gravity Turn (t >= 10s): Miringkan sedikit ke timur, lalu ikuti vektor kecepatan
            
            if (t < 10.0_wp) then
                thrust_dir = r_unit ! Tegak lurus menjauhi pusat bumi
            else if (t < 20.0_wp) then
                ! Pitch kick: Miringkan sedikit (misal 85 derajat elevasi)
                ! Kita asumsikan peluncuran di ekuator, miring ke Timur (sumbu X)
                ! r_unit biasanya [0,0,1] jika start di kutub, tapi mari kita anggap
                ! posisi awal di ekuator [R, 0, 0].
                ! Untuk simplifikasi, kita blend vektor posisi dan vektor target.
                thrust_dir = r_unit + [0.1_wp, 0.1_wp, 0.0_wp] 
                thrust_dir = thrust_dir / norm2(thrust_dir)
            else
                ! Gravity Turn: Ikuti vektor kecepatan (Zero Angle of Attack)
                ! Ini meminimalkan stres aerodinamis
                thrust_dir = v_unit
            end if
            
            F_thrust = thrust_force_mag * thrust_dir
            
            ! Hitung pengurangan massa (dm/dt)
            ! dm/dt = - Thrust / (Isp * g0)
            mass_flow_rate = -(cfg%thrust) / (cfg%isp * g0)
        end if
        
        ! --- TOTAL GAYA & PERCEPATAN ---
        F_total = F_gravity + F_drag + F_thrust
        
        ! Turunan Posisi = Kecepatan
        ds%r = s%v
        
        ! Turunan Kecepatan = Percepatan (F/m)
        ds%v = F_total / s%mass
        
        ! Turunan Massa = Laju aliran massa
        ds%mass = mass_flow_rate
        
    end function get_derivatives

end module mod_physics
