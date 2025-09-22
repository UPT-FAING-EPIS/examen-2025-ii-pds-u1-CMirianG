# Script de despliegue limpio con credenciales exactas
Write-Host "DESPLEGANDO A AZURE - DESPLIEGUE LIMPIO" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

# Credenciales exactas del publish profile
$APP_NAME = "asistenciaestudiantil"
$DEPLOY_URL = "https://asistenciaestudiantil-gefwbed2f7h8csd8.scm.canadacentral-01.azurewebsites.net:443"
$USERNAME = "`$asistenciaestudiantil"
$PASSWORD = "3RrMsv2R08Z2X75TEhosm0x3Khz1JcmbLTDhLES6A1rxgjzpkxD5NKnDisjX"
$APP_URL = "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net"

Write-Host "Configuracion del despliegue:" -ForegroundColor Yellow
Write-Host "   App Name: $APP_NAME" -ForegroundColor White
Write-Host "   Deploy URL: $DEPLOY_URL" -ForegroundColor White
Write-Host "   App URL: $APP_URL" -ForegroundColor White
Write-Host ""

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "backend/AttendanceSystem.API/AttendanceSystem.API.csproj")) {
    Write-Host "Error: No se encontro el proyecto backend" -ForegroundColor Red
    Write-Host "Asegurate de ejecutar este script desde la raiz del proyecto" -ForegroundColor Red
    exit 1
}

# Limpiar todo
Write-Host "Limpiando archivos anteriores..." -ForegroundColor Yellow
Remove-Item "deploy.zip" -Force -ErrorAction SilentlyContinue
Remove-Item "backend/AttendanceSystem.API/publish" -Recurse -Force -ErrorAction SilentlyContinue

# Navegar al backend
Write-Host "Navegando al directorio backend..." -ForegroundColor Yellow
Set-Location "backend/AttendanceSystem.API"

# Restaurar dependencias
Write-Host "Restaurando dependencias..." -ForegroundColor Yellow
dotnet restore --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al restaurar dependencias" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Compilar proyecto
Write-Host "Compilando proyecto..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al compilar el proyecto" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Publicar proyecto
Write-Host "Publicando proyecto..." -ForegroundColor Yellow
dotnet publish --configuration Release --no-build --output ./publish --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al publicar el proyecto" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Verificar que se creo la carpeta publish
if (-not (Test-Path "./publish")) {
    Write-Host "Error: No se creo la carpeta publish" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

# Crear archivo ZIP
Write-Host "Creando archivo ZIP..." -ForegroundColor Yellow
Compress-Archive -Path "./publish/*" -DestinationPath "../../deploy.zip" -Force

# Verificar que se creo el ZIP
if (-not (Test-Path "../../deploy.zip")) {
    Write-Host "Error: No se creo el archivo ZIP" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host "Archivo ZIP creado exitosamente" -ForegroundColor Green

# Volver al directorio raiz
Set-Location "../.."

# Desplegar usando Invoke-RestMethod con las credenciales exactas
Write-Host "Desplegando a Azure App Service..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Yellow

# Crear credenciales para autenticacion basica
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$USERNAME`:$PASSWORD"))

# Headers para la peticion
$headers = @{
    "Authorization" = "Basic $credentials"
    "Content-Type" = "application/zip"
}

try {
    Write-Host "Iniciando despliegue ZIP..." -ForegroundColor Yellow
    $zipPath = Resolve-Path "deploy.zip"
    
    # Hacer el despliegue
    $response = Invoke-RestMethod -Uri "$DEPLOY_URL/api/zipdeploy" -Method POST -InFile $zipPath -Headers $headers -TimeoutSec 300
    
    Write-Host "Despliegue completado exitosamente!" -ForegroundColor Green
    
} catch {
    Write-Host "Error en el despliegue: $($_.Exception.Message)" -ForegroundColor Red
    
    # Intentar con curl si esta disponible
    Write-Host "Intentando con curl..." -ForegroundColor Yellow
    try {
        $curlCmd = "curl -X POST -u `"$USERNAME`:$PASSWORD`" --data-binary `"@$zipPath`" $DEPLOY_URL/api/zipdeploy --fail"
        $curlResult = Invoke-Expression $curlCmd 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Despliegue completado con curl!" -ForegroundColor Green
        } else {
            Write-Host "Error con curl: $curlResult" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "Error con curl: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

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
Write-Host "La aplicacion puede tardar 2-3 minutos en iniciarse completamente." -ForegroundColor Yellow
Write-Host "Probar en unos minutos en: $APP_URL" -ForegroundColor Green
