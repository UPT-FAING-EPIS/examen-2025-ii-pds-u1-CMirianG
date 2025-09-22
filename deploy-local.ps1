# PowerShell script para desplegar el sistema localmente
# Usage: .\deploy-local.ps1

Write-Host "🚀 Iniciando despliegue local del Attendance System..." -ForegroundColor Green

# Verificar prerrequisitos
Write-Host "🔍 Verificando prerrequisitos..." -ForegroundColor Yellow

# Verificar .NET 8
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET Version: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ .NET no encontrado. Instala .NET 8 SDK" -ForegroundColor Red
    exit 1
}

# Verificar Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js Version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js no encontrado. Instala Node.js 18+" -ForegroundColor Red
    exit 1
}

# Verificar npm
try {
    $npmVersion = npm --version
    Write-Host "✅ npm Version: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 Configurando Backend..." -ForegroundColor Cyan

# Navegar al directorio del backend
Set-Location "backend\AttendanceSystem.API"

# Restaurar dependencias
Write-Host "📥 Restaurando dependencias del backend..." -ForegroundColor Yellow
dotnet restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error restaurando dependencias del backend" -ForegroundColor Red
    exit 1
}

# Compilar el proyecto
Write-Host "🔨 Compilando backend..." -ForegroundColor Yellow
dotnet build --configuration Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error compilando el backend" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Backend configurado correctamente" -ForegroundColor Green

# Volver al directorio raíz
Set-Location "..\.."

Write-Host ""
Write-Host "📦 Configurando Frontend..." -ForegroundColor Cyan

# Navegar al directorio del frontend
Set-Location "frontend"

# Instalar dependencias
Write-Host "📥 Instalando dependencias del frontend..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error instalando dependencias del frontend" -ForegroundColor Red
    exit 1
}

# Compilar el frontend
Write-Host "🔨 Compilando frontend..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error compilando el frontend" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Frontend configurado correctamente" -ForegroundColor Green

# Volver al directorio raíz
Set-Location ".."

Write-Host ""
Write-Host "🎉 ¡Despliegue local completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Ejecuta el backend: .\start-backend.ps1" -ForegroundColor White
Write-Host "2. Ejecuta el frontend: .\start-frontend.ps1" -ForegroundColor White
Write-Host "3. Abre http://localhost:3000 en tu navegador" -ForegroundColor White
Write-Host "4. Swagger API disponible en: http://localhost:5000/swagger" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: Usa Ctrl+C para detener los servidores" -ForegroundColor Yellow
