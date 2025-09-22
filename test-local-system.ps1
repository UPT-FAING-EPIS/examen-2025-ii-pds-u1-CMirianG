# PowerShell script para probar el sistema local
# Usage: .\test-local-system.ps1

Write-Host "🧪 Probando sistema local del Attendance System..." -ForegroundColor Green

$backendUrl = "http://localhost:5000"
$frontendUrl = "http://localhost:3000"
$testsPassed = 0
$totalTests = 6

# Función para hacer requests HTTP
function Test-HttpEndpoint {
    param(
        [string]$Url,
        [string]$TestName,
        [int]$ExpectedStatus = 200
    )
    
    try {
        Write-Host "🔍 Probando: $TestName..." -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq $ExpectedStatus) {
            Write-Host "✅ $TestName - OK ($($response.StatusCode))" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $TestName - Expected $ExpectedStatus, got $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $TestName - Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host ""
Write-Host "🔍 Verificando que los servicios estén ejecutándose..." -ForegroundColor Cyan

# Test 1: Health Check del Backend
if (Test-HttpEndpoint -Url "$backendUrl/health" -TestName "Backend Health Check") {
    $testsPassed++
}

# Test 2: Swagger UI del Backend
if (Test-HttpEndpoint -Url "$backendUrl/swagger/index.html" -TestName "Swagger UI") {
    $testsPassed++
}

# Test 3: API Endpoint - Students
if (Test-HttpEndpoint -Url "$backendUrl/api/attendance/students" -TestName "Students API") {
    $testsPassed++
}

# Test 4: API Endpoint - Courses
if (Test-HttpEndpoint -Url "$backendUrl/api/courses" -TestName "Courses API") {
    $testsPassed++
}

# Test 5: API Endpoint - Sessions
if (Test-HttpEndpoint -Url "$backendUrl/api/sessions" -TestName "Sessions API") {
    $testsPassed++
}

# Test 6: Frontend
if (Test-HttpEndpoint -Url $frontendUrl -TestName "Frontend") {
    $testsPassed++
}

Write-Host ""
Write-Host "📊 Resultados de las pruebas:" -ForegroundColor Cyan
Write-Host "✅ Pruebas pasadas: $testsPassed/$totalTests" -ForegroundColor White

if ($testsPassed -eq $totalTests) {
    Write-Host "🎉 ¡Todas las pruebas pasaron! El sistema está funcionando correctamente." -ForegroundColor Green
} elseif ($testsPassed -ge ($totalTests / 2)) {
    Write-Host "⚠️ Algunas pruebas fallaron. Revisa los servicios." -ForegroundColor Yellow
} else {
    Write-Host "❌ La mayoría de pruebas fallaron. Verifica que los servicios estén ejecutándose." -ForegroundColor Red
}

Write-Host ""
Write-Host "🔗 URLs del sistema:" -ForegroundColor Cyan
Write-Host "• Frontend: $frontendUrl" -ForegroundColor White
Write-Host "• Backend API: $backendUrl" -ForegroundColor White
Write-Host "• Swagger UI: $backendUrl/swagger" -ForegroundColor White
Write-Host "• Health Check: $backendUrl/health" -ForegroundColor White

Write-Host ""
Write-Host "💡 Para iniciar el sistema si no está ejecutándose:" -ForegroundColor Yellow
Write-Host "   .\start-all.ps1" -ForegroundColor White

Write-Host ""
Write-Host "📝 Para ver logs de los servicios:" -ForegroundColor Yellow
Write-Host "   Get-Job | Receive-Job" -ForegroundColor White
