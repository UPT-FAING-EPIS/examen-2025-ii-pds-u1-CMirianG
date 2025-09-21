# Script de deployment manual para Azure App Service
# Ejecutar desde PowerShell en el directorio raíz del proyecto

Write-Host "🚀 Iniciando deployment manual..." -ForegroundColor Green

# Navegar al backend
Set-Location "backend\AttendanceSystem.API"

# Limpiar y compilar
Write-Host "📦 Limpiando proyecto..." -ForegroundColor Yellow
dotnet clean

Write-Host "📦 Restaurando dependencias..." -ForegroundColor Yellow
dotnet restore

Write-Host "🔨 Compilando aplicación..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore

Write-Host "📦 Publicando aplicación..." -ForegroundColor Yellow
dotnet publish --configuration Release --no-build --output ".\publish"

# Crear archivo ZIP para deployment
Write-Host "📦 Creando archivo ZIP..." -ForegroundColor Yellow
if (Test-Path ".\publish.zip") { Remove-Item ".\publish.zip" }
Compress-Archive -Path ".\publish\*" -DestinationPath ".\publish.zip"

Write-Host "✅ Aplicación lista para deployment!" -ForegroundColor Green
Write-Host "📁 Archivo ZIP creado: backend\AttendanceSystem.API\publish.zip" -ForegroundColor Cyan

Write-Host ""
Write-Host "🌐 Próximos pasos:" -ForegroundColor Yellow
Write-Host "1. Ve a Azure Portal: https://portal.azure.com" -ForegroundColor White
Write-Host "2. Busca tu App Service: asistenciaestudiantil" -ForegroundColor White
Write-Host "3. Ve a Deployment Center" -ForegroundColor White
Write-Host "4. Sube el archivo publish.zip" -ForegroundColor White
Write-Host ""
Write-Host "🎯 Tu app estará en:" -ForegroundColor Green
Write-Host "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
