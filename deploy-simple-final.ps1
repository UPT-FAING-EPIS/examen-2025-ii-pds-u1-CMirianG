# Script super simple para desplegar
Write-Host "DESPLEGANDO A AZURE - VERSION SIMPLE" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Ir al directorio del backend
Set-Location "backend/AttendanceSystem.API"

# Limpiar
Remove-Item "./publish" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "../../deploy.zip" -Force -ErrorAction SilentlyContinue

# Compilar
Write-Host "Compilando..." -ForegroundColor Yellow
dotnet publish --configuration Release --output ./publish

# Crear ZIP
Write-Host "Creando ZIP..." -ForegroundColor Yellow
Compress-Archive -Path "./publish/*" -DestinationPath "../../deploy.zip" -Force

# Volver al directorio raiz
Set-Location "../.."

# Desplegar
Write-Host "Desplegando..." -ForegroundColor Yellow
az webapp deployment source config-zip --resource-group PDS --name asistenciaestudiantil --src "deploy.zip"

Write-Host "Despliegue completado!" -ForegroundColor Green
Write-Host "URL: http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
Write-Host "Swagger: http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net/swagger" -ForegroundColor Cyan

# Limpiar
Remove-Item "deploy.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "backend/AttendanceSystem.API/publish" -Recurse -Force -ErrorAction SilentlyContinue
