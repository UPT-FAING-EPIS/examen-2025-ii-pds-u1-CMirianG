# PowerShell script para iniciar el frontend
# Usage: .\start-frontend.ps1

Write-Host "🚀 Iniciando Frontend del Attendance System..." -ForegroundColor Green

# Navegar al directorio del frontend
Set-Location "frontend"

Write-Host "📍 Directorio actual: $(Get-Location)" -ForegroundColor Yellow

# Verificar que existe el package.json
if (-not (Test-Path "package.json")) {
    Write-Host "❌ No se encontró package.json. Asegúrate de estar en el directorio correcto." -ForegroundColor Red
    exit 1
}

# Verificar que las dependencias están instaladas
if (-not (Test-Path "node_modules")) {
    Write-Host "⚠️ node_modules no encontrado. Instalando dependencias..." -ForegroundColor Yellow
    npm install
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error instalando dependencias" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🏃 Iniciando servidor de desarrollo..." -ForegroundColor Cyan
Write-Host "🌐 URL: http://localhost:3000" -ForegroundColor White
Write-Host "🔧 Modo: Desarrollo (hot reload habilitado)" -ForegroundColor White
Write-Host ""
Write-Host "💡 Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
Write-Host ""

# Iniciar el servidor de desarrollo
npm run dev -- --port 3000
