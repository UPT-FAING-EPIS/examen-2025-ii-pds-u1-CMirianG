# Script para desplegar con credenciales reales de Azure
Write-Host "DESPLEGANDO A AZURE CON CREDENCIALES REALES" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

# Variables extraidas del publish profile
$APP_NAME = "asistenciaestudiantil"
$RESOURCE_GROUP = "asistenciaestudiantil"
$FULL_APP_NAME = "asistenciaestudiantil-gefwbed2f7h8csd8"
$APP_URL = "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net"
$USERNAME = "`$asistenciaestudiantil"
$PASSWORD = "3RrMsv2R08Z2X75TEhosm0x3Khz1JcmbLTDhLES6A1rxgjzpkxD5NKnDisjX"
$DEPLOY_URL = "https://asistenciaestudiantil-gefwbed2f7h8csd8.scm.canadacentral-01.azurewebsites.net:443"

Write-Host "Configuracion del despliegue:" -ForegroundColor Yellow
Write-Host "   App Name: $APP_NAME" -ForegroundColor White
Write-Host "   Full App Name: $FULL_APP_NAME" -ForegroundColor White
Write-Host "   URL: $APP_URL" -ForegroundColor White
Write-Host "   Deploy URL: $DEPLOY_URL" -ForegroundColor White
Write-Host ""

# Verificar que estamos en el directorio correcto
Write-Host "Verificando directorio..." -ForegroundColor Yellow
if (-not (Test-Path "backend/AttendanceSystem.API/AttendanceSystem.API.csproj")) {
    Write-Host "Error: No se encontro el proyecto backend" -ForegroundColor Red
    Write-Host "Asegurate de ejecutar este script desde la raiz del proyecto" -ForegroundColor Red
    exit 1
}
Write-Host "Proyecto backend encontrado" -ForegroundColor Green

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

# Desplegar usando curl con las credenciales reales
Write-Host "Desplegando a Azure App Service..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Yellow

# Usar curl para hacer el despliegue ZIP
$zipPath = Resolve-Path "../deploy.zip"
Write-Host "Archivo ZIP creado en: $zipPath" -ForegroundColor Cyan

# Crear las credenciales para curl
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$USERNAME`:$PASSWORD"))

Write-Host "Iniciando despliegue ZIP..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$DEPLOY_URL/api/zipdeploy" -Method POST -InFile $zipPath -ContentType "application/zip" -Headers @{Authorization="Basic $credentials"} -TimeoutSec 300
    Write-Host "Despliegue completado exitosamente!" -ForegroundColor Green
} catch {
    Write-Host "Error en el despliegue: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Intentando con Azure CLI como alternativa..." -ForegroundColor Yellow
    
    # Alternativa con Azure CLI
    Set-Location "../.."
    az webapp deployment source config-zip --resource-group $RESOURCE_GROUP --name $FULL_APP_NAME --src "deploy.zip"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error al desplegar con Azure CLI" -ForegroundColor Red
        exit 1
    }
    Write-Host "Despliegue completado con Azure CLI!" -ForegroundColor Green
}

# Limpiar archivos temporales
Write-Host "Limpiando archivos temporales..." -ForegroundColor Yellow
Remove-Item "../deploy.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "./publish" -Recurse -Force -ErrorAction SilentlyContinue

# Volver al directorio raiz
Set-Location "../.."

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
Write-Host "   4. Desplegar el frontend" -ForegroundColor White
