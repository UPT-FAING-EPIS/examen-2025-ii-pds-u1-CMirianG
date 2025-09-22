# Script para desplegar a Azure desde Visual Studio Code
Write-Host "🚀 DESPLEGANDO ATTENDANCE SYSTEM A AZURE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# Verificar que estamos en el directorio correcto
Write-Host "📁 Verificando directorio..." -ForegroundColor Yellow
if (-not (Test-Path "backend/AttendanceSystem.API/AttendanceSystem.API.csproj")) {
    Write-Host "❌ Error: No se encontró el proyecto backend" -ForegroundColor Red
    Write-Host "Asegúrate de ejecutar este script desde la raíz del proyecto" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Proyecto backend encontrado" -ForegroundColor Green

# Verificar Azure CLI
Write-Host "🔍 Verificando Azure CLI..." -ForegroundColor Yellow
try {
    $azureVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI version: $($azureVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI no está instalado" -ForegroundColor Red
    Write-Host "Instala Azure CLI desde: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Yellow
    exit 1
}

# Iniciar sesión en Azure
Write-Host "🔐 Iniciando sesión en Azure..." -ForegroundColor Yellow
az login --output none
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al iniciar sesión en Azure" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Sesión iniciada en Azure" -ForegroundColor Green

# Configurar variables
$APP_NAME = "assistenciaestudiantil-gefwbed2f7h8csd8"
$RESOURCE_GROUP = "attendance-system-rg"
$LOCATION = "canadacentral"

Write-Host "📋 Configuración:" -ForegroundColor Yellow
Write-Host "   App Name: $APP_NAME" -ForegroundColor White
Write-Host "   Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "   Location: $LOCATION" -ForegroundColor White
Write-Host ""

# Navegar al directorio del backend
Write-Host "📁 Navegando al directorio backend..." -ForegroundColor Yellow
Set-Location "backend/AttendanceSystem.API"
Write-Host "✅ En directorio: $(Get-Location)" -ForegroundColor Green

# Restaurar dependencias
Write-Host "📦 Restaurando dependencias..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al restaurar dependencias" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}
Write-Host "✅ Dependencias restauradas" -ForegroundColor Green

# Compilar en modo Release
Write-Host "🔨 Compilando proyecto..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al compilar el proyecto" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}
Write-Host "✅ Proyecto compilado exitosamente" -ForegroundColor Green

# Publicar el proyecto
Write-Host "📤 Publicando proyecto..." -ForegroundColor Yellow
dotnet publish --configuration Release --no-build --output ./publish
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al publicar el proyecto" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}
Write-Host "✅ Proyecto publicado exitosamente" -ForegroundColor Green

# Desplegar a Azure usando ZIP
Write-Host "🚀 Desplegando a Azure App Service..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Yellow

# Crear archivo ZIP
Write-Host "📦 Creando archivo ZIP..." -ForegroundColor Yellow
Compress-Archive -Path "./publish/*" -DestinationPath "../deploy.zip" -Force

# Desplegar usando Azure CLI
Write-Host "☁️ Subiendo a Azure..." -ForegroundColor Yellow
az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $APP_NAME --src "../deploy.zip" --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al desplegar a Azure" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host "✅ Despliegue completado exitosamente!" -ForegroundColor Green

# Limpiar archivos temporales
Write-Host "🧹 Limpiando archivos temporales..." -ForegroundColor Yellow
Remove-Item "../deploy.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "./publish" -Recurse -Force -ErrorAction SilentlyContinue

# Volver al directorio raíz
Set-Location "../.."

# Verificar el despliegue
Write-Host "🔍 Verificando despliegue..." -ForegroundColor Yellow
$APP_URL = "https://$APP_NAME.azurewebsites.net"
Write-Host "🌐 URL de la aplicación: $APP_URL" -ForegroundColor Cyan

# Probar el endpoint de salud
Write-Host "🏥 Probando endpoint de salud..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$APP_URL/api/health" -Method GET -TimeoutSec 30
    Write-Host "✅ Endpoint de salud respondió correctamente" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Endpoint de salud no responde aún (esto es normal, puede tomar unos minutos)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 ¡DESPLIEGUE COMPLETADO!" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Información del despliegue:" -ForegroundColor White
Write-Host "   🌐 URL de la aplicación: $APP_URL" -ForegroundColor Cyan
Write-Host "   📚 Swagger UI: $APP_URL/swagger" -ForegroundColor Cyan
Write-Host "   🏥 Health Check: $APP_URL/api/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ El backend está ahora desplegado en Azure!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Configurar la base de datos en Azure SQL" -ForegroundColor White
Write-Host "   2. Actualizar las variables de entorno en Azure" -ForegroundColor White
Write-Host "   3. Probar la aplicación" -ForegroundColor White
Write-Host "   4. Desplegar el frontend" -ForegroundColor White
