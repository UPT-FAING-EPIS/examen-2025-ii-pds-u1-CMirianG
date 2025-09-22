# Script simple para iniciar el Attendance System
Write-Host "Iniciando Attendance System..." -ForegroundColor Green

# Iniciar Backend
Write-Host "1. Iniciando Backend..." -ForegroundColor Yellow
$backendPath = Join-Path $PWD "backend\AttendanceSystem.API"
Start-Job -ScriptBlock { param($path) Set-Location $path; dotnet run --urls "http://localhost:5000" } -ArgumentList $backendPath -Name "Backend"

# Esperar que el backend se inicie
Start-Sleep -Seconds 5

# Iniciar Frontend
Write-Host "2. Iniciando Frontend..." -ForegroundColor Yellow
$frontendPath = Join-Path $PWD "frontend"
Start-Job -ScriptBlock { param($path) Set-Location $path; npm run dev } -ArgumentList $frontendPath -Name "Frontend"

Write-Host "Sistema iniciado!" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend: http://localhost:5000" -ForegroundColor Cyan
Write-Host "Swagger: http://localhost:5000/swagger" -ForegroundColor Cyan
