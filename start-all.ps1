# PowerShell script para iniciar todo el sistema
# Usage: .\start-all.ps1

Write-Host "🚀 Iniciando Attendance System completo..." -ForegroundColor Green

# Verificar si PowerShell tiene soporte para jobs
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "❌ Se requiere PowerShell 5.0 o superior para ejecutar jobs" -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Verificando configuración..." -ForegroundColor Yellow

# Verificar que los archivos de configuración existen
if (-not (Test-Path "backend\AttendanceSystem.API\appsettings.json")) {
    Write-Host "❌ appsettings.json no encontrado en el backend" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "frontend\package.json")) {
    Write-Host "❌ package.json no encontrado en el frontend" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Configuración verificada" -ForegroundColor Green

Write-Host ""
Write-Host "🏃 Iniciando Backend..." -ForegroundColor Cyan

# Iniciar backend en un job separado
$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location "backend\AttendanceSystem.API"
    dotnet run --urls="http://localhost:5000"
}

Write-Host "✅ Backend iniciado (Job ID: $($backendJob.Id))" -ForegroundColor Green

# Esperar un poco para que el backend se inicie
Write-Host "⏳ Esperando que el backend se inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "🏃 Iniciando Frontend..." -ForegroundColor Cyan

# Iniciar frontend en un job separado
$frontendJob = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    Set-Location "frontend"
    npm run dev -- --port 3000
}

Write-Host "✅ Frontend iniciado (Job ID: $($frontendJob.Id))" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 ¡Sistema iniciado completamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 URLs del sistema:" -ForegroundColor Cyan
Write-Host "🌐 Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "📡 Backend API: http://localhost:5000" -ForegroundColor White
Write-Host "📚 Swagger UI: http://localhost:5000/swagger" -ForegroundColor White
Write-Host "❤️ Health Check: http://localhost:5000/health" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Monitoreo de jobs:" -ForegroundColor Yellow
Write-Host "Backend Job ID: $($backendJob.Id)" -ForegroundColor White
Write-Host "Frontend Job ID: $($frontendJob.Id)" -ForegroundColor White
Write-Host ""
Write-Host "📝 Comandos útiles:" -ForegroundColor Cyan
Write-Host "• Ver logs del backend: Receive-Job -Id $($backendJob.Id)" -ForegroundColor White
Write-Host "• Ver logs del frontend: Receive-Job -Id $($frontendJob.Id)" -ForegroundColor White
Write-Host "• Detener backend: Stop-Job -Id $($backendJob.Id)" -ForegroundColor White
Write-Host "• Detener frontend: Stop-Job -Id $($frontendJob.Id)" -ForegroundColor White
Write-Host "• Detener todo: .\stop-all.ps1" -ForegroundColor White
Write-Host ""

# Función para mostrar logs en tiempo real
function Show-Logs {
    Write-Host "📊 Mostrando logs en tiempo real (Ctrl+C para salir)..." -ForegroundColor Yellow
    try {
        while ($true) {
            # Mostrar logs del backend
            $backendOutput = Receive-Job -Id $backendJob.Id -ErrorAction SilentlyContinue
            if ($backendOutput) {
                Write-Host "[BACKEND] $backendOutput" -ForegroundColor Green
            }
            
            # Mostrar logs del frontend
            $frontendOutput = Receive-Job -Id $frontendJob.Id -ErrorAction SilentlyContinue
            if ($frontendOutput) {
                Write-Host "[FRONTEND] $frontendOutput" -ForegroundColor Blue
            }
            
            Start-Sleep -Seconds 1
        }
    } catch {
        Write-Host "`n🛑 Monitoreo detenido" -ForegroundColor Yellow
    }
}

# Preguntar si quiere ver logs
$response = Read-Host "¿Quieres ver los logs en tiempo real? (s/n)"
if ($response -eq "s" -or $response -eq "S" -or $response -eq "y" -or $response -eq "Y") {
    Show-Logs
}
