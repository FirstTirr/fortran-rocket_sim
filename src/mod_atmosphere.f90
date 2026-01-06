! mod_atmosphere.f90
! Modul untuk menghitung properti atmosfer.
! Drag (hambatan udara) sangat penting dalam peluncuran roket.

module mod_atmosphere
    use mod_precision
    use mod_constants
    implicit none
    
contains

    ! Fungsi untuk menghitung kerapatan udara berdasarkan ketinggian
    ! Menggunakan model eksponensial sederhana: rho = rho0 * exp(-h / H)
    function get_air_density(altitude) result(rho)
        real(wp), intent(in) :: altitude ! Ketinggian dari permukaan (m)
        real(wp) :: rho
        
        if (altitude < 0.0_wp) then
            rho = RHO_0
        else if (altitude > 1000000.0_wp) then
            ! Di luar angkasa (di atas 1000km), anggap vakum
            rho = 0.0_wp
        else
            rho = RHO_0 * exp(-altitude / H_SCALE)
        end if
    end function get_air_density

end module mod_atmosphere
