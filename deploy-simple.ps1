# Script simple para desplegar a Azure
Write-Host "DESPLEGANDO ATTENDANCE SYSTEM A AZURE" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Variables
$APP_NAME = "assistenciaestudiantil-gefwbed2f7h8csd8"
$RESOURCE_GROUP = "attendance-system-rg"

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "   App Name: $APP_NAME" -ForegroundColor White
Write-Host "   Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host ""

# Verificar Azure CLI
Write-Host "Verificando Azure CLI..." -ForegroundColor Yellow
try {
    az version --output none
    Write-Host "Azure CLI encontrado" -ForegroundColor Green
} catch {
    Write-Host "Azure CLI no esta instalado" -ForegroundColor Red
    Write-Host "Instala Azure CLI desde: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Iniciar sesion en Azure
Write-Host "Iniciando sesion en Azure..." -ForegroundColor Yellow
az login
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al iniciar sesion en Azure" -ForegroundColor Red
    exit 1
}
Write-Host "Sesion iniciada en Azure" -ForegroundColor Green

# Navegar al directorio del backend
Write-Host "Navegando al directorio backend..." -ForegroundColor Yellow
Set-Location "backend/AttendanceSystem.API"
Write-Host "En directorio: $(Get-Location)" -ForegroundColor Green

# Restaurar dependencias
Write-Host "Restaurando dependencias..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al restaurar dependencias" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}
Write-Host "Dependencias restauradas" -ForegroundColor Green

# Compilar en modo Release
Write-Host "Compilando proyecto..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al compilar el proyecto" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}
Write-Host "Proyecto compilado exitosamente" -ForegroundColor Green

# Publicar el proyecto
Write-Host "Publicando proyecto..." -ForegroundColor Yellow
dotnet publish --configuration Release --no-build --output ./publish
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al publicar el proyecto" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}
Write-Host "Proyecto publicado exitosamente" -ForegroundColor Green

# Crear archivo ZIP
Write-Host "Creando archivo ZIP..." -ForegroundColor Yellow
Compress-Archive -Path "./publish/*" -DestinationPath "../deploy.zip" -Force

# Desplegar usando Azure CLI
Write-Host "Desplegando a Azure App Service..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Yellow

az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $APP_NAME --src "../deploy.zip"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al desplegar a Azure" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host "Despliegue completado exitosamente!" -ForegroundColor Green

# Limpiar archivos temporales
Write-Host "Limpiando archivos temporales..." -ForegroundColor Yellow
Remove-Item "../deploy.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "./publish" -Recurse -Force -ErrorAction SilentlyContinue

# Volver al directorio raiz
Set-Location "../.."

# Verificar el despliegue
$APP_URL = "https://$APP_NAME.azurewebsites.net"
Write-Host "URL de la aplicacion: $APP_URL" -ForegroundColor Cyan

Write-Host ""
Write-Host "DESPLIEGUE COMPLETADO!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "Informacion del despliegue:" -ForegroundColor White
Write-Host "   URL de la aplicacion: $APP_URL" -ForegroundColor Cyan
Write-Host "   Swagger UI: $APP_URL/swagger" -ForegroundColor Cyan
Write-Host "   Health Check: $APP_URL/api/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "El backend esta ahora desplegado en Azure!" -ForegroundColor Green
