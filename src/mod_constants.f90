! mod_constants.f90
! Modul ini berisi konstanta fisika dan parameter planet (Bumi).

module mod_constants
    use mod_precision
    implicit none
    
    ! Konstanta Fisika
    real(wp), parameter :: G = 6.67430e-11_wp        ! Konstanta Gravitasi Universal (m^3 kg^-1 s^-2)
    real(wp), parameter :: PI = 3.14159265358979_wp
    
    ! Parameter Bumi
    real(wp), parameter :: M_EARTH = 5.972e24_wp     ! Massa Bumi (kg)
    real(wp), parameter :: R_EARTH = 6371.0e3_wp     ! Jari-jari Bumi (m)
    real(wp), parameter :: g0 = 9.80665_wp           ! Percepatan gravitasi standar (m/s^2)
    
    ! Parameter Atmosfer
    real(wp), parameter :: RHO_0 = 1.225_wp          ! Kerapatan udara di permukaan laut (kg/m^3)
    real(wp), parameter :: H_SCALE = 8500.0_wp       ! Skala ketinggian atmosfer (m) - untuk model eksponensial
end module mod_constants
