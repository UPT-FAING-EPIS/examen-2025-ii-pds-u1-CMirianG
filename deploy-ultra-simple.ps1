# Script ultra simple para desplegar
Write-Host "DESPLEGANDO ULTRA SIMPLE" -ForegroundColor Green

# Ir al backend
cd backend/AttendanceSystem.API

# Limpiar
Remove-Item publish -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item ../../deploy.zip -Force -ErrorAction SilentlyContinue

# Compilar
Write-Host "Compilando..." -ForegroundColor Yellow
dotnet publish -c Release -o publish

# Crear ZIP
Write-Host "Creando ZIP..." -ForegroundColor Yellow
Compress-Archive -Path publish/* -DestinationPath ../../deploy.zip -Force

# Volver
cd ../..

# Desplegar
Write-Host "Desplegando..." -ForegroundColor Yellow
az webapp deploy --resource-group PDS --name asistenciaestudiantil --src-path deploy.zip

Write-Host "Listo!" -ForegroundColor Green
Write-Host "URL: http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
