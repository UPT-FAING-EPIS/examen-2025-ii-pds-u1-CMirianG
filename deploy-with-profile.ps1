# Despliegue usando el perfil de publicación
Write-Host "DESPLEGANDO CON PERFIL DE PUBLICACION" -ForegroundColor Green

# Variables del perfil
$username = '$asistenciaestudiantil'
$password = '3RrMsv2R08Z2X75TEhosm0x3Khz1JcmbLTDhLES6A1rxgjzpkxD5NKnDisjX'
$deployUrl = 'https://asistenciaestudiantil-gefwbed2f7h8csd8.scm.canadacentral-01.azurewebsites.net:443'

# Ir al backend
Set-Location backend/AttendanceSystem.API

# Limpiar y compilar
Remove-Item publish -Recurse -Force -ErrorAction SilentlyContinue
dotnet publish -c Release -o publish

# Crear ZIP
Compress-Archive -Path publish/* -DestinationPath ../../deploy.zip -Force

# Volver
Set-Location ../..

# Desplegar con credenciales
$zipPath = Resolve-Path deploy.zip
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$username`:$password"))

try {
    Invoke-RestMethod -Uri "$deployUrl/api/zipdeploy" -Method POST -InFile $zipPath -Headers @{
        "Authorization" = "Basic $credentials"
        "Content-Type" = "application/zip"
    } -TimeoutSec 300
    
    Write-Host "Despliegue exitoso!" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "URL: http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
