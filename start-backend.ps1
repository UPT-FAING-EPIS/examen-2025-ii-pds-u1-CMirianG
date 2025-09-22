# PowerShell script para iniciar el backend
# Usage: .\start-backend.ps1

Write-Host "🚀 Iniciando Backend del Attendance System..." -ForegroundColor Green

# Navegar al directorio del backend
Set-Location "backend\AttendanceSystem.API"

Write-Host "📍 Directorio actual: $(Get-Location)" -ForegroundColor Yellow

# Verificar que existe el archivo de proyecto
if (-not (Test-Path "AttendanceSystem.API.csproj")) {
    Write-Host "❌ No se encontró el archivo del proyecto. Asegúrate de estar en el directorio correcto." -ForegroundColor Red
    exit 1
}

# Verificar conexión a la base de datos
Write-Host "🔍 Verificando configuración de la base de datos..." -ForegroundColor Yellow

# Leer la configuración
$configFile = "appsettings.json"
if (Test-Path $configFile) {
    $config = Get-Content $configFile | ConvertFrom-Json
    if ($config.ConnectionStrings.DefaultConnection) {
        Write-Host "✅ Connection string configurada" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Connection string no encontrada en appsettings.json" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ appsettings.json no encontrado" -ForegroundColor Red
}

Write-Host ""
Write-Host "🏃 Iniciando servidor backend..." -ForegroundColor Cyan
Write-Host "📡 URL: http://localhost:5000" -ForegroundColor White
Write-Host "📚 Swagger: http://localhost:5000/swagger" -ForegroundColor White
Write-Host "❤️ Health: http://localhost:5000/health" -ForegroundColor White
Write-Host ""
Write-Host "💡 Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Iniciar el servidor
dotnet run --urls="http://localhost:5000"
