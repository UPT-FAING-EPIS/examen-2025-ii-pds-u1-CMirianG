# Script para desplegar frontend a Azure Static Web Apps
Write-Host "DESPLEGANDO FRONTEND A AZURE STATIC WEB APPS" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Crear ZIP del frontend
Write-Host "Creando ZIP del frontend..." -ForegroundColor Yellow
Compress-Archive -Path "frontend/dist/*" -DestinationPath "frontend-deploy.zip" -Force

Write-Host "ZIP creado: frontend-deploy.zip" -ForegroundColor Green
Write-Host ""

Write-Host "INSTRUCCIONES PARA AZURE STATIC WEB APPS:" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Ve a Azure Portal: https://portal.azure.com" -ForegroundColor White
Write-Host "2. Busca 'Static Web Apps' y crea uno nuevo" -ForegroundColor White
Write-Host "3. Configuracion:" -ForegroundColor White
Write-Host "   - Subscription: Tu suscripcion" -ForegroundColor White
Write-Host "   - Resource Group: PDS" -ForegroundColor White
Write-Host "   - Name: asistenciaestudiantil-frontend" -ForegroundColor White
Write-Host "   - Region: Canada Central" -ForegroundColor White
Write-Host "   - Source: Other" -ForegroundColor White
Write-Host "   - App location: /" -ForegroundColor White
Write-Host "   - Output location: dist" -ForegroundColor White
Write-Host ""
Write-Host "4. Una vez creado, ve a 'Overview' y haz clic en 'Browse'" -ForegroundColor White
Write-Host "5. Sube el archivo frontend-deploy.zip" -ForegroundColor White
Write-Host ""

Write-Host "BACKEND YA FUNCIONANDO:" -ForegroundColor Green
Write-Host "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
