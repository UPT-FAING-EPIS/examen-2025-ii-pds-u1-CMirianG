# PowerShell script para detener todo el sistema
# Usage: .\stop-all.ps1

Write-Host "🛑 Deteniendo Attendance System..." -ForegroundColor Red

# Obtener todos los jobs relacionados con el proyecto
$backendJobs = Get-Job | Where-Object { $_.Command -like "*dotnet run*" -and $_.State -eq "Running" }
$frontendJobs = Get-Job | Where-Object { $_.Command -like "*npm run dev*" -and $_.State -eq "Running" }

$totalJobs = $backendJobs.Count + $frontendJobs.Count

if ($totalJobs -eq 0) {
    Write-Host "ℹ️ No se encontraron procesos del sistema ejecutándose" -ForegroundColor Yellow
    exit 0
}

Write-Host "🔍 Encontrados $totalJobs procesos ejecutándose..." -ForegroundColor Yellow

# Detener jobs del backend
if ($backendJobs.Count -gt 0) {
    Write-Host "🛑 Deteniendo backend..." -ForegroundColor Yellow
    foreach ($job in $backendJobs) {
        Write-Host "   • Deteniendo job ID: $($job.Id)" -ForegroundColor White
        Stop-Job -Id $job.Id -ErrorAction SilentlyContinue
        Remove-Job -Id $job.Id -ErrorAction SilentlyContinue
    }
    Write-Host "✅ Backend detenido" -ForegroundColor Green
}

# Detener jobs del frontend
if ($frontendJobs.Count -gt 0) {
    Write-Host "🛑 Deteniendo frontend..." -ForegroundColor Yellow
    foreach ($job in $frontendJobs) {
        Write-Host "   • Deteniendo job ID: $($job.Id)" -ForegroundColor White
        Stop-Job -Id $job.Id -ErrorAction SilentlyContinue
        Remove-Job -Id $job.Id -ErrorAction SilentlyContinue
    }
    Write-Host "✅ Frontend detenido" -ForegroundColor Green
}

# También detener procesos que puedan estar ejecutándose directamente
Write-Host "🔍 Verificando procesos adicionales..." -ForegroundColor Yellow

# Detener procesos de dotnet
$dotnetProcesses = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*AttendanceSystem*" }
if ($dotnetProcesses) {
    foreach ($process in $dotnetProcesses) {
        Write-Host "   • Deteniendo proceso dotnet PID: $($process.Id)" -ForegroundColor White
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
}

# Detener procesos de node
$nodeProcesses = Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*vite*" }
if ($nodeProcesses) {
    foreach ($process in $nodeProcesses) {
        Write-Host "   • Deteniendo proceso node PID: $($process.Id)" -ForegroundColor White
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "🎉 ¡Sistema detenido completamente!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Para reiniciar el sistema, ejecuta:" -ForegroundColor Cyan
Write-Host "   .\start-all.ps1" -ForegroundColor White
