# Usando el comando nuevo de Azure CLI
Write-Host "DESPLEGANDO CON COMANDO NUEVO" -ForegroundColor Green

# Ir al backend
Set-Location backend/AttendanceSystem.API

# Limpiar y compilar
Remove-Item publish -Recurse -Force -ErrorAction SilentlyContinue
dotnet publish -c Release -o publish

# Crear ZIP
Compress-Archive -Path publish/* -DestinationPath ../../deploy.zip -Force

# Volver
Set-Location ../..

# Usar el comando nuevo
Write-Host "Desplegando..." -ForegroundColor Yellow
az webapp deploy --resource-group PDS --name asistenciaestudiantil --src-path deploy.zip --type zip

Write-Host "Despliegue completado!" -ForegroundColor Green
Write-Host "URL: http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
