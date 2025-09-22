# Script para desplegar directamente con las credenciales del publish profile
Write-Host "DESPLEGANDO DIRECTAMENTE A AZURE" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Variables del publish profile
$APP_NAME = "asistenciaestudiantil"
$FULL_APP_NAME = "asistenciaestudiantil-gefwbed2f7h8csd8"
$APP_URL = "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net"
$USERNAME = "`$asistenciaestudiantil"
$PASSWORD = "3RrMsv2R08Z2X75TEhosm0x3Khz1JcmbLTDhLES6A1rxgjzpkxD5NKnDisjX"
$DEPLOY_URL = "https://asistenciaestudiantil-gefwbed2f7h8csd8.scm.canadacentral-01.azurewebsites.net:443"

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "   App Name: $APP_NAME" -ForegroundColor White
Write-Host "   URL: $APP_URL" -ForegroundColor White
Write-Host ""

# Verificar directorio
if (-not (Test-Path "backend/AttendanceSystem.API/AttendanceSystem.API.csproj")) {
    Write-Host "Error: No se encontro el proyecto backend" -ForegroundColor Red
    exit 1
}

# Navegar al backend
Set-Location "backend/AttendanceSystem.API"

# Limpiar publicaciones anteriores
Write-Host "Limpiando publicaciones anteriores..." -ForegroundColor Yellow
Remove-Item "./publish" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "../deploy.zip" -Force -ErrorAction SilentlyContinue

# Restaurar y compilar
Write-Host "Restaurando dependencias..." -ForegroundColor Yellow
dotnet restore --verbosity quiet

Write-Host "Compilando proyecto..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore --verbosity quiet

Write-Host "Publicando proyecto..." -ForegroundColor Yellow
dotnet publish --configuration Release --no-build --output ./publish --verbosity quiet

# Crear ZIP
Write-Host "Creando archivo ZIP..." -ForegroundColor Yellow
Compress-Archive -Path "./publish/*" -DestinationPath "../deploy.zip" -Force

# Desplegar con curl
Write-Host "Desplegando a Azure..." -ForegroundColor Yellow
$zipPath = Resolve-Path "../deploy.zip"
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$USERNAME`:$PASSWORD"))

try {
    # Usar Invoke-RestMethod para el despliegue
    $headers = @{
        "Authorization" = "Basic $credentials"
        "Content-Type" = "application/zip"
    }
    
    $response = Invoke-RestMethod -Uri "$DEPLOY_URL/api/zipdeploy" -Method POST -InFile $zipPath -Headers $headers -TimeoutSec 300
    Write-Host "Despliegue completado exitosamente!" -ForegroundColor Green
} catch {
    Write-Host "Error en despliegue: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Intentando metodo alternativo..." -ForegroundColor Yellow
    
    # Metodo alternativo con curl si esta disponible
    try {
        $curlCmd = "curl -X POST -u `"$USERNAME`:$PASSWORD`" --data-binary `"@$zipPath`" $DEPLOY_URL/api/zipdeploy"
        Invoke-Expression $curlCmd
        Write-Host "Despliegue completado con curl!" -ForegroundColor Green
    } catch {
        Write-Host "Error con curl tambien. Usando Azure CLI..." -ForegroundColor Yellow
        
        # Volver al directorio raiz
        Set-Location "../.."
        
        # Usar Azure CLI con el nombre completo
        az webapp deployment source config-zip --name $FULL_APP_NAME --src "deploy.zip"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Despliegue completado con Azure CLI!" -ForegroundColor Green
        } else {
            Write-Host "Error en todos los metodos de despliegue" -ForegroundColor Red
            exit 1
        }
    }
}

# Limpiar
Write-Host "Limpiando archivos temporales..." -ForegroundColor Yellow
Remove-Item "../deploy.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "./publish" -Recurse -Force -ErrorAction SilentlyContinue

# Volver al directorio raiz
Set-Location "../.."

Write-Host ""
Write-Host "DESPLIEGUE COMPLETADO!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host ""
Write-Host "URL de la aplicacion: $APP_URL" -ForegroundColor Cyan
Write-Host "Swagger UI: $APP_URL/swagger" -ForegroundColor Cyan
Write-Host "Health Check: $APP_URL/api/health" -ForegroundColor Cyan
Write-Host ""
Write-Host "La aplicacion puede tardar unos minutos en iniciarse completamente." -ForegroundColor Yellow
