# Script para desplegar frontend a Azure Static Web Apps
Write-Host "DESPLEGANDO FRONTEND A AZURE STATIC WEB APPS" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Ir al directorio frontend
Set-Location frontend

# Verificar que existe la carpeta dist
if (-not (Test-Path "dist")) {
    Write-Host "Error: No se encontro la carpeta dist. Ejecutando build..." -ForegroundColor Yellow
    npm run build
}

# Volver al directorio raiz
Set-Location ..

# Crear ZIP del frontend
Write-Host "Creando ZIP del frontend..." -ForegroundColor Yellow
Compress-Archive -Path "frontend/dist/*" -DestinationPath "frontend-dist.zip" -Force

Write-Host ""
Write-Host "FRONTEND LISTO PARA DESPLIEGUE!" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host ""
Write-Host "Archivo creado: frontend-dist.zip" -ForegroundColor Cyan
Write-Host ""
Write-Host "OPCIONES DE DESPLIEGUE:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. GitHub Pages (si configuras correctamente):" -ForegroundColor White
Write-Host "   https://cmiriang.github.io/examen-2025-ii-pds-u1-CMirianG/" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Azure Static Web Apps:" -ForegroundColor White
Write-Host "   - Ve a Azure Portal" -ForegroundColor White
Write-Host "   - Crea un Static Web App" -ForegroundColor White
Write-Host "   - Sube el archivo frontend-dist.zip" -ForegroundColor White
Write-Host ""
Write-Host "3. Netlify (alternativa gratuita):" -ForegroundColor White
Write-Host "   - Ve a https://netlify.com" -ForegroundColor White
Write-Host "   - Arrastra la carpeta frontend/dist" -ForegroundColor White
Write-Host ""
Write-Host "Backend API funcionando:" -ForegroundColor Green
Write-Host "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
