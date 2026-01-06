! mod_precision.f90
! Modul ini mendefinisikan presisi angka yang akan digunakan di seluruh program.
! Menggunakan real64 (double precision) untuk akurasi tinggi seperti standar NASA.

module mod_precision
    use iso_fortran_env, only: real64
    implicit none
    
    ! wp = Working Precision. Kita set ke 64-bit float.
    integer, parameter :: wp = real64 
end module mod_precision
