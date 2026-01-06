! mod_rocket.f90
! Modul ini mendefinisikan struktur data untuk Roket.
! Kita menggunakan Derived Types (OOP di Fortran) untuk mengelompokkan data.

module mod_rocket
    use mod_precision
    implicit none
    
    ! Tipe data untuk menyimpan status roket saat ini
    type :: RocketState
        real(wp) :: r(3)    ! Posisi [x, y, z] (m) relative terhadap pusat Bumi
        real(wp) :: v(3)    ! Kecepatan [vx, vy, vz] (m/s)
        real(wp) :: mass    ! Massa total saat ini (kg)
    end type RocketState

    ! Tipe data untuk konfigurasi roket (Stage/Tahapan)
    type :: RocketConfig
        real(wp) :: dry_mass        ! Massa roket tanpa bahan bakar (kg)
        real(wp) :: fuel_mass       ! Massa bahan bakar awal (kg)
        real(wp) :: thrust          ! Gaya dorong mesin (Newton)
        real(wp) :: isp             ! Impuls Spesifik (detik) - efisiensi mesin
        real(wp) :: burn_time       ! Lama waktu pembakaran (detik)
        real(wp) :: drag_coeff      ! Koefisien hambatan udara (Cd)
        real(wp) :: area            ! Luas penampang roket (m^2)
    end type RocketConfig

    interface operator(+)
        module procedure add_states
    end interface

    interface operator(*)
        module procedure scale_state
    end interface

contains

    ! Fungsi penjumlahan untuk integrator (State + State)
    function add_states(s1, s2) result(res)
        type(RocketState), intent(in) :: s1, s2
        type(RocketState) :: res
        res%r = s1%r + s2%r
        res%v = s1%v + s2%v
        res%mass = s1%mass + s2%mass
    end function add_states

    ! Fungsi perkalian skalar untuk integrator (State * scalar)
    function scale_state(s, val) result(res)
        type(RocketState), intent(in) :: s
        real(wp), intent(in) :: val
        type(RocketState) :: res
        res%r = s%r * val
        res%v = s%v * val
        res%mass = s%mass * val
    end function scale_state

end module mod_rocket
