# Pruebas específicas para el sistema desplegado en Azure
$AzureUrl = "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net"

Write-Host "🌐 PRUEBAS DEL SISTEMA EN AZURE" -ForegroundColor Green
Write-Host "URL: $AzureUrl" -ForegroundColor Cyan
Write-Host ""

# Función para pruebas con retry
function Test-AzureEndpoint {
    param($Url, $Description, $MaxRetries = 3)
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Write-Host "🔍 Intento $i/$MaxRetries - $Description" -ForegroundColor Yellow
            
            $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec 30
            
            if ($response.StatusCode -eq 200) {
                Write-Host "✅ ÉXITO: $Description" -ForegroundColor Green
                return $true
            }
        } catch {
            Write-Host "⚠️  Intento $i fallido: $($_.Exception.Message)" -ForegroundColor Yellow
            if ($i -lt $MaxRetries) {
                Write-Host "⏳ Esperando 10 segundos antes del siguiente intento..." -ForegroundColor Gray
                Start-Sleep -Seconds 10
            }
        }
    }
    
    Write-Host "❌ ERROR: $Description falló después de $MaxRetries intentos" -ForegroundColor Red
    return $false
}

# PRUEBAS PRINCIPALES
Write-Host "=== PRUEBAS DE CONECTIVIDAD ===" -ForegroundColor Magenta

$healthOk = Test-AzureEndpoint "$AzureUrl/health" "Health Check"
$swaggerOk = Test-AzureEndpoint "$AzureUrl/swagger/index.html" "Swagger Documentation"
$coursesOk = Test-AzureEndpoint "$AzureUrl/api/courses" "API Courses"
$studentsOk = Test-AzureEndpoint "$AzureUrl/api/attendance/students" "API Students"

Write-Host ""
Write-Host "=== PRUEBAS DE FUNCIONALIDAD ===" -ForegroundColor Magenta

# Probar creación de curso
try {
    Write-Host "🔍 Probando creación de curso..." -ForegroundColor Yellow
    
    $newCourse = @{
        name = "Curso de Prueba Azure"
        code = "AZURE001"
        description = "Curso para verificar funcionamiento en Azure"
        instructorName = "Instructor Azure"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$AzureUrl/api/courses" -Method POST -Body $newCourse -ContentType "application/json"
    Write-Host "✅ ÉXITO: Curso creado con ID $($response.id)" -ForegroundColor Green
    
} catch {
    Write-Host "❌ ERROR: No se pudo crear curso - $($_.Exception.Message)" -ForegroundColor Red
}

# RESUMEN FINAL
Write-Host ""
Write-Host "=== RESUMEN FINAL ===" -ForegroundColor Magenta

$totalTests = 4
$passedTests = @($healthOk, $swaggerOk, $coursesOk, $studentsOk) | Where-Object {$_} | Measure-Object | Select-Object -ExpandProperty Count

Write-Host ""
Write-Host "📊 RESULTADOS:" -ForegroundColor Cyan
Write-Host "   ✅ Pruebas exitosas: $passedTests/$totalTests" -ForegroundColor Green
Write-Host "   📈 Porcentaje de éxito: $([math]::Round(($passedTests/$totalTests)*100, 1))%" -ForegroundColor Cyan

if ($passedTests -eq $totalTests) {
    Write-Host ""
    Write-Host "🎉 ¡SISTEMA COMPLETAMENTE FUNCIONAL EN AZURE!" -ForegroundColor Green
    Write-Host "✅ Todas las pruebas pasaron exitosamente" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 URLs disponibles:" -ForegroundColor Cyan
    Write-Host "   API: $AzureUrl" -ForegroundColor White
    Write-Host "   Swagger: $AzureUrl/swagger" -ForegroundColor White
    Write-Host "   Health: $AzureUrl/health" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Próximos pasos:" -ForegroundColor Yellow
    Write-Host "   1. Desplegar frontend en Azure Static Web Apps" -ForegroundColor White
    Write-Host "   2. Configurar dominio personalizado (opcional)" -ForegroundColor White
    Write-Host "   3. Configurar monitoreo con Application Insights" -ForegroundColor White
    
} elseif ($passedTests -ge ($totalTests * 0.75)) {
    Write-Host ""
    Write-Host "⚠️  SISTEMA MAYORMENTE FUNCIONAL" -ForegroundColor Yellow
    Write-Host "💡 Algunas pruebas fallaron, pero el sistema básico funciona" -ForegroundColor Yellow
    
} else {
    Write-Host ""
    Write-Host "❌ SISTEMA CON PROBLEMAS SIGNIFICATIVOS" -ForegroundColor Red
    Write-Host "🔧 Requiere correcciones antes de usar en producción" -ForegroundColor Red
}

Write-Host ""
Write-Host "📝 Para más detalles, revisa los logs de Azure App Service en:" -ForegroundColor Gray
Write-Host "   https://portal.azure.com → App Service → Log stream" -ForegroundColor Gray
