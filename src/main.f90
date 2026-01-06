! main.f90
! Program Utama: Simulasi Peluncuran Roket ke Orbit
! Program ini mensimulasikan fisika peluncuran roket dari permukaan Bumi hingga mencapai orbit.
! Data output disimpan ke 'flight_data.csv' untuk dianalisis.

program rocket_launch_sim
    use mod_precision
    use mod_constants
    use mod_rocket
    use mod_physics
    use mod_integrator
    implicit none
    
    ! Variabel Simulasi
    type(RocketState) :: current_state, next_state
    type(RocketConfig) :: falcon_config
    real(wp) :: t, dt, t_max
    logical :: engine_on
    integer :: step, output_interval
    integer :: file_unit
    real(wp) :: altitude, velocity, downrange_dist
    real(wp) :: input_fuel, input_time
    
    ! Setup Parameter Simulasi
    t = 0.0_wp
    dt = 0.1_wp          ! Time step 0.1 detik (presisi tinggi)
    output_interval = 10 ! Simpan data setiap 10 step (1 detik)
    
    ! Konfigurasi Roket (Mirip Falcon 9 First Stage)
    falcon_config%dry_mass = 25600.0_wp      ! Massa kosong (kg)
    falcon_config%thrust = 7607000.0_wp      ! Gaya dorong (N) - Merlin 1D Engines
    falcon_config%isp = 282.0_wp             ! Impuls Spesifik (s) - Sea Level
    falcon_config%burn_time = 162.0_wp       ! Waktu bakar (s)
    falcon_config%drag_coeff = 0.3_wp        ! Aerodinamika
    falcon_config%area = 10.0_wp             ! Luas penampang (m^2)
    
    ! --- INTERAKSI USER (BAHASA INDONESIA) ---
    print *, "=================================================="
    print *, "   SIMULATOR PELUNCURAN ROKET (NASA/SPACEX)       "
    print *, "=================================================="
    print *, "Selamat datang, Komandan Misi!"
    print *, "Mari kita konfigurasi roket Anda sebelum peluncuran."
    print *, ""
    
    ! Input Bahan Bakar
    print *, "1. Masukkan jumlah bahan bakar (kg)."
    print *, "   (Rekomendasi: 395700 untuk orbit normal)"
    print *, "   (Semakin banyak bahan bakar, semakin berat roketnya)"
    write(*, '(A)', advance='no') "   Input Bahan Bakar > "
    read(*, *) input_fuel
    
    if (input_fuel <= 0.0_wp) then
        print *, "   [INFO] Input tidak valid. Menggunakan default: 395700 kg"
        falcon_config%fuel_mass = 395700.0_wp
    else
        falcon_config%fuel_mass = input_fuel
    end if
    print *, ""

    ! Input Durasi Simulasi
    print *, "2. Berapa lama kita akan memantau roket ini? (detik)"
    print *, "   (Rekomendasi: 600 detik untuk melihat sampai luar angkasa)"
    write(*, '(A)', advance='no') "   Input Durasi (detik) > "
    read(*, *) input_time
    
    if (input_time <= 0.0_wp) then
        print *, "   [INFO] Input tidak valid. Menggunakan default: 600 detik"
        t_max = 600.0_wp
    else
        t_max = input_time
    end if
    print *, ""
    
    print *, "--------------------------------------------------"
    print *, "Sistem Siap. Memulai hitung mundur..."
    print *, "3... 2... 1..."
    print *, "MELUNCUR! (LIFTOFF!)"
    print *, "--------------------------------------------------"
    
    ! Kondisi Awal (Di Launchpad)
    ! Posisi: Di permukaan Bumi (R_EARTH), di Ekuator (sumbu X)
    current_state%r = [R_EARTH, 0.0_wp, 0.0_wp]
    
    ! Kecepatan Awal: 0 relatif terhadap permukaan (tapi ikut rotasi bumi)
    ! Untuk simplifikasi, kita mulai dari 0 absolut dulu, nanti roket yang kerja keras.
    current_state%v = [0.0_wp, 0.0_wp, 0.0_wp]
    
    ! Massa Awal: Kosong + Bahan Bakar
    current_state%mass = falcon_config%dry_mass + falcon_config%fuel_mass
    
    ! Buka file untuk menyimpan data
    open(newunit=file_unit, file='viz/flight_data.csv', status='replace')
    write(file_unit, *) 'Time(s), Altitude(km), Velocity(m/s), Mass(kg), Accel(G)'
    
    ! Loop Utama Simulasi
    do step = 0, int(t_max/dt)
        
        ! Cek apakah mesin masih menyala (ada bahan bakar & belum habis waktu)
        if (t < falcon_config%burn_time .and. current_state%mass > falcon_config%dry_mass) then
            engine_on = .true.
        else
            engine_on = .false.
            if (abs(t - falcon_config%burn_time) < dt) then
                print *, "T+", t, "s: MESIN MATI (MECO) - Bahan Bakar Habis / Jadwal Selesai"
            end if
        end if
        
        ! Hitung parameter untuk display/log
        altitude = (norm2(current_state%r) - R_EARTH) / 1000.0_wp ! km
        velocity = norm2(current_state%v)
        
        ! Simpan data ke CSV
        if (mod(step, output_interval) == 0) then
            write(file_unit, '(F10.2, ",", F10.2, ",", F10.2, ",", F10.2)') &
                t, altitude, velocity, current_state%mass
        end if
        
        ! Tampilkan status ke layar setiap 10 detik simulasi
        if (mod(step, int(10.0/dt)) == 0) then
            print '(A, F6.1, A, F8.2, A, F8.2, A)', &
                "Waktu: ", t, "s | Tinggi: ", altitude, " km | Kecepatan: ", velocity, " m/s"
        end if
        
        ! Integrasi ke langkah waktu berikutnya (RK4)
        call rk4_step(t, dt, current_state, falcon_config, engine_on, next_state)
        
        ! Update state dan waktu
        current_state = next_state
        t = t + dt
        
        ! Cek jika jatuh kembali ke bumi (Crash)
        if (altitude < 0.0_wp .and. t > 1.0_wp) then
            print *, "BAHAYA: Roket jatuh kembali ke permukaan bumi! Misi Gagal."
            exit
        end if
        
    end do
    
    print *, "=================================================="
    print *, "              SIMULASI SELESAI                    "
    print *, "=================================================="
    print *, "Data penerbangan telah disimpan ke 'flight_data.csv'"
    print *, "Silakan jalankan visualisasi Python untuk melihat grafik."
    close(file_unit)

end program rocket_launch_sim
