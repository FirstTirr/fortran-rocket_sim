# Build Script for Rocket Sim
# Ini adalah script otomatis untuk mengompilasi proyek Fortran Anda.
# Script ini menangani urutan file, folder, dan error secara otomatis.

$ErrorActionPreference = "Stop"

# 1. Buat Folder (jika belum ada)
New-Item -ItemType Directory -Force -Path "build", "mod", "exe" | Out-Null

# 2. Daftar File (URUTAN SANGAT PENTING!)
# File yang paling dasar (tidak butuh modul lain) harus di atas.
$files = @(
    "src/mod_precision.f90",
    "src/mod_constants.f90",
    "src/mod_rocket.f90",
    "src/mod_atmosphere.f90",
    "src/mod_physics.f90",
    "src/mod_integrator.f90",
    "src/main.f90"
)

# 3. Proses Kompilasi
Write-Host "Starting Build Process..." -ForegroundColor Cyan

$object_files = @()

foreach ($file in $files) {
    # Tentukan nama output file object (.o)
    $filename = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $output_obj = "build/$filename.o"
    $object_files += $output_obj
    
    Write-Host "  Compiling: $file" -NoNewline
    
    # Jalankan gfortran
    # -J mod : Simpan/Cari modul di folder mod
    # -c     : Compile saja (jangan link dulu)
    # -o     : Simpan hasil .o di folder build
    try {
        gfortran -J mod -c $file -o $output_obj
        Write-Host " [OK]" -ForegroundColor Green
    }
    catch {
        Write-Host " [FAILED]" -ForegroundColor Red
        Write-Host "Error compiling $file"
        exit 1
    }
}

# 4. Proses Linking (Penggabungan)
Write-Host "Linking Executable..." -NoNewline
try {
    gfortran $object_files -o exe/rocket_sim.exe
    Write-Host " [OK]" -ForegroundColor Green
}
catch {
    Write-Host " [FAILED]" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuild Success!" -ForegroundColor Green
Write-Host "Run your simulation with: ./exe/rocket_sim.exe" -ForegroundColor Yellow
