# Deployment directo con Kudu API
$appName = "asistenciaestudiantil"
$username = '$asistenciaestudiantil'
$password = "3RrMsv2R08Z2X75TEhosm0x3Khz1JcmbLTDhLES6A1rxgjzpkxD5NKnDisjX"
$zipFile = "backend\AttendanceSystem.API\publish.zip"

Write-Host "🚀 Desplegando a Azure App Service..." -ForegroundColor Green

# Verificar que el archivo ZIP existe
if (-not (Test-Path $zipFile)) {
    Write-Host "❌ Error: No se encuentra el archivo $zipFile" -ForegroundColor Red
    Write-Host "💡 Ejecuta primero: cd backend\AttendanceSystem.API && dotnet publish -c Release -o publish" -ForegroundColor Yellow
    exit 1
}

# Crear credenciales base64
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

# URL de Kudu para ZIP deployment
$kuduUrl = "https://asistenciaestudiantil-gefwbed2f7h8csd8.scm.canadacentral-01.azurewebsites.net/api/zipdeploy"

try {
    # Hacer deployment
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
        "Content-Type" = "application/zip"
    }
    
    Write-Host "📤 Subiendo archivo ZIP..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $kuduUrl -Method Post -InFile $zipFile -Headers $headers
    
    Write-Host "✅ Deployment completado!" -ForegroundColor Green
    Write-Host "🌐 Tu aplicación estará disponible en:" -ForegroundColor Cyan
    Write-Host "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor White
    Write-Host "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net/swagger" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error en deployment:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Solución manual:" -ForegroundColor Yellow
    Write-Host "1. Ve a Azure Portal" -ForegroundColor White
    Write-Host "2. App Service → Deployment Center" -ForegroundColor White
    Write-Host "3. Sube el archivo ZIP manualmente" -ForegroundColor White
}
