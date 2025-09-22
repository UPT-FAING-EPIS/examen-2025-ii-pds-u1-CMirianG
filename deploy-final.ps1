# Despliegue final con credenciales exactas
Write-Host "DESPLEGANDO CON CREDENCIALES EXACTAS" -ForegroundColor Green

# Credenciales del perfil
$username = '$asistenciaestudiantil'
$password = '3RrMsv2R08Z2X75TEhosm0x3Khz1JcmbLTDhLES6A1rxgjzpkxD5NKnDisjX'
$deployUrl = 'https://asistenciaestudiantil-gefwbed2f7h8csd8.scm.canadacentral-01.azurewebsites.net:443'

# Verificar que existe el ZIP
if (-not (Test-Path "app-deploy.zip")) {
    Write-Host "Error: No se encontro app-deploy.zip" -ForegroundColor Red
    exit 1
}

Write-Host "Archivo ZIP encontrado: $(Get-ChildItem app-deploy.zip | Select-Object -ExpandProperty Length) bytes" -ForegroundColor Green

# Crear credenciales
$credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$username`:$password"))

# Headers
$headers = @{
    "Authorization" = "Basic $credentials"
    "Content-Type" = "application/zip"
}

# Desplegar
Write-Host "Desplegando..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$deployUrl/api/zipdeploy" -Method POST -InFile "app-deploy.zip" -Headers $headers -TimeoutSec 300
    Write-Host "Despliegue exitoso!" -ForegroundColor Green
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host "URL: http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan