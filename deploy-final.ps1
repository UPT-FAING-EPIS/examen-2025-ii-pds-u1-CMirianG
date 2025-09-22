# Script final para desplegar con el resource group correcto
Write-Host "DESPLEGANDO A AZURE - VERSION FINAL" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""

# Variables correctas
$APP_NAME = "asistenciaestudiantil"
$RESOURCE_GROUP = "PDS"
$FULL_APP_NAME = "asistenciaestudiantil-gefwbed2f7h8csd8"
$APP_URL = "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net"

Write-Host "Configuracion correcta:" -ForegroundColor Yellow
Write-Host "   App Name: $APP_NAME" -ForegroundColor White
Write-Host "   Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "   URL: $APP_URL" -ForegroundColor White
Write-Host ""

# Verificar directorio
if (-not (Test-Path "backend/AttendanceSystem.API/AttendanceSystem.API.csproj")) {
    Write-Host "Error: No se encontro el proyecto backend" -ForegroundColor Red
    exit 1
}

# Navegar al backend
Write-Host "Navegando al directorio backend..." -ForegroundColor Yellow
Set-Location "backend/AttendanceSystem.API"

# Limpiar
Write-Host "Limpiando archivos anteriores..." -ForegroundColor Yellow
Remove-Item "./publish" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "../deploy.zip" -Force -ErrorAction SilentlyContinue

# Compilar y publicar
Write-Host "Restaurando dependencias..." -ForegroundColor Yellow
dotnet restore --verbosity quiet

Write-Host "Compilando proyecto..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore --verbosity quiet

Write-Host "Publicando proyecto..." -ForegroundColor Yellow
dotnet publish --configuration Release --no-build --output ./publish --verbosity quiet

# Crear ZIP
Write-Host "Creando archivo ZIP..." -ForegroundColor Yellow
Compress-Archive -Path "./publish/*" -DestinationPath "../deploy.zip" -Force

# Desplegar con Azure CLI usando el resource group correcto
Write-Host "Desplegando a Azure App Service..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Yellow

# Volver al directorio raiz
Set-Location "../.."

# Usar Azure CLI con el resource group correcto
az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $FULL_APP_NAME --src "deploy.zip"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al desplegar con Azure CLI" -ForegroundColor Red
    exit 1
}

Write-Host "Despliegue completado exitosamente!" -ForegroundColor Green

# Limpiar archivos temporales
Write-Host "Limpiando archivos temporales..." -ForegroundColor Yellow
Remove-Item "deploy.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "backend/AttendanceSystem.API/publish" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "DESPLIEGUE COMPLETADO!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "Informacion del despliegue:" -ForegroundColor White
Write-Host "   URL de la aplicacion: $APP_URL" -ForegroundColor Cyan
Write-Host "   Swagger UI: $APP_URL/swagger" -ForegroundColor Cyan
Write-Host "   Health Check: $APP_URL/api/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "Base de datos configurada:" -ForegroundColor White
Write-Host "   Servidor: asistenciaestudiantil-server.database.windows.net" -ForegroundColor Cyan
Write-Host "   Base de datos: asistenciaestudiantil-database" -ForegroundColor Cyan
Write-Host "   Usuario: asistenciaestudiantil-server-admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "El backend esta ahora desplegado en Azure!" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Esperar unos minutos para que la aplicacion se inicie" -ForegroundColor White
Write-Host "   2. Probar la aplicacion en: $APP_URL" -ForegroundColor White
Write-Host "   3. Verificar Swagger en: $APP_URL/swagger" -ForegroundColor White
Write-Host "   4. Las tablas de la base de datos se crearan automaticamente" -ForegroundColor White
