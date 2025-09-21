# Script de pruebas automatizado para el Sistema de Asistencia
param(
    [string]$BaseUrl = "http://localhost:5000"
)

Write-Host "🧪 Iniciando pruebas del Sistema de Asistencia..." -ForegroundColor Green
Write-Host "🌐 URL Base: $BaseUrl" -ForegroundColor Cyan
Write-Host ""

$testResults = @()

function Test-Endpoint {
    param($Url, $Description)
    
    try {
        Write-Host "🔍 Probando: $Description" -ForegroundColor Yellow
        $response = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ ÉXITO: $Description" -ForegroundColor Green
            $script:testResults += @{Test = $Description; Status = "ÉXITO"; Details = "HTTP 200"}
            return $true
        } else {
            Write-Host "⚠️  ADVERTENCIA: $Description - Status: $($response.StatusCode)" -ForegroundColor Yellow
            $script:testResults += @{Test = $Description; Status = "ADVERTENCIA"; Details = "HTTP $($response.StatusCode)"}
            return $false
        }
    } catch {
        Write-Host "❌ ERROR: $Description - $($_.Exception.Message)" -ForegroundColor Red
        $script:testResults += @{Test = $Description; Status = "ERROR"; Details = $_.Exception.Message}
        return $false
    }
}

function Test-ApiEndpoint {
    param($Endpoint, $Description)
    
    try {
        Write-Host "🔍 Probando API: $Description" -ForegroundColor Yellow
        $response = Invoke-RestMethod -Uri "$BaseUrl$Endpoint" -Method GET
        
        Write-Host "✅ ÉXITO: $Description" -ForegroundColor Green
        $script:testResults += @{Test = $Description; Status = "ÉXITO"; Details = "Datos recibidos correctamente"}
        
        # Mostrar algunos datos si es array
        if ($response -is [array]) {
            Write-Host "   📊 Registros encontrados: $($response.Count)" -ForegroundColor Cyan
        }
        
        return $true
    } catch {
        Write-Host "❌ ERROR: $Description - $($_.Exception.Message)" -ForegroundColor Red
        $script:testResults += @{Test = $Description; Status = "ERROR"; Details = $_.Exception.Message}
        return $false
    }
}

# PRUEBAS DE CONECTIVIDAD
Write-Host "=== PRUEBAS DE CONECTIVIDAD ===" -ForegroundColor Magenta

Test-Endpoint "$BaseUrl/health" "Health Check"
Test-Endpoint "$BaseUrl/swagger/index.html" "Swagger Documentation"

# PRUEBAS DE API
Write-Host ""
Write-Host "=== PRUEBAS DE API ===" -ForegroundColor Magenta

Test-ApiEndpoint "/api/courses" "Obtener Cursos"
Test-ApiEndpoint "/api/attendance/students" "Obtener Estudiantes"
Test-ApiEndpoint "/api/sessions" "Obtener Sesiones"
Test-ApiEndpoint "/api/attendance" "Obtener Asistencias"
Test-ApiEndpoint "/api/reports/attendance" "Obtener Reportes"
Test-ApiEndpoint "/api/reports/attendance/alerts" "Obtener Alertas"

# PRUEBAS DE DATOS
Write-Host ""
Write-Host "=== VERIFICACIÓN DE DATOS ===" -ForegroundColor Magenta

try {
    $courses = Invoke-RestMethod -Uri "$BaseUrl/api/courses" -Method GET
    if ($courses.Count -ge 2) {
        Write-Host "✅ ÉXITO: Datos de cursos cargados ($($courses.Count) cursos)" -ForegroundColor Green
        $testResults += @{Test = "Datos de Cursos"; Status = "ÉXITO"; Details = "$($courses.Count) cursos encontrados"}
    } else {
        Write-Host "⚠️  ADVERTENCIA: Pocos cursos encontrados ($($courses.Count))" -ForegroundColor Yellow
        $testResults += @{Test = "Datos de Cursos"; Status = "ADVERTENCIA"; Details = "Solo $($courses.Count) cursos"}
    }
    
    $students = Invoke-RestMethod -Uri "$BaseUrl/api/attendance/students" -Method GET
    if ($students.Count -ge 3) {
        Write-Host "✅ ÉXITO: Datos de estudiantes cargados ($($students.Count) estudiantes)" -ForegroundColor Green
        $testResults += @{Test = "Datos de Estudiantes"; Status = "ÉXITO"; Details = "$($students.Count) estudiantes encontrados"}
    } else {
        Write-Host "⚠️  ADVERTENCIA: Pocos estudiantes encontrados ($($students.Count))" -ForegroundColor Yellow
        $testResults += @{Test = "Datos de Estudiantes"; Status = "ADVERTENCIA"; Details = "Solo $($students.Count) estudiantes"}
    }
} catch {
    Write-Host "❌ ERROR: No se pudieron verificar los datos" -ForegroundColor Red
    $testResults += @{Test = "Verificación de Datos"; Status = "ERROR"; Details = $_.Exception.Message}
}

# RESUMEN DE PRUEBAS
Write-Host ""
Write-Host "=== RESUMEN DE PRUEBAS ===" -ForegroundColor Magenta

$successCount = ($testResults | Where-Object {$_.Status -eq "ÉXITO"}).Count
$warningCount = ($testResults | Where-Object {$_.Status -eq "ADVERTENCIA"}).Count
$errorCount = ($testResults | Where-Object {$_.Status -eq "ERROR"}).Count
$totalTests = $testResults.Count

Write-Host ""
Write-Host "📊 ESTADÍSTICAS:" -ForegroundColor Cyan
Write-Host "   ✅ Éxitos: $successCount" -ForegroundColor Green
Write-Host "   ⚠️  Advertencias: $warningCount" -ForegroundColor Yellow
Write-Host "   ❌ Errores: $errorCount" -ForegroundColor Red
Write-Host "   📝 Total: $totalTests" -ForegroundColor White

# Mostrar detalles
Write-Host ""
Write-Host "📋 DETALLES:" -ForegroundColor Cyan
foreach ($result in $testResults) {
    $color = switch ($result.Status) {
        "ÉXITO" { "Green" }
        "ADVERTENCIA" { "Yellow" }
        "ERROR" { "Red" }
    }
    Write-Host "   $($result.Status): $($result.Test) - $($result.Details)" -ForegroundColor $color
}

# CONCLUSIÓN
Write-Host ""
if ($errorCount -eq 0) {
    Write-Host "🎉 ¡SISTEMA FUNCIONANDO CORRECTAMENTE!" -ForegroundColor Green
    Write-Host "✅ Todas las pruebas críticas pasaron" -ForegroundColor Green
} elseif ($errorCount -le 2) {
    Write-Host "⚠️  SISTEMA PARCIALMENTE FUNCIONAL" -ForegroundColor Yellow
    Write-Host "💡 Algunos componentes necesitan atención" -ForegroundColor Yellow
} else {
    Write-Host "❌ SISTEMA CON PROBLEMAS" -ForegroundColor Red
    Write-Host "🔧 Requiere correcciones antes de usar" -ForegroundColor Red
}

Write-Host ""
Write-Host "🌐 URLs para verificar manualmente:" -ForegroundColor Cyan
Write-Host "   Health: $BaseUrl/health" -ForegroundColor White
Write-Host "   Swagger: $BaseUrl/swagger" -ForegroundColor White
Write-Host "   API: $BaseUrl/api/courses" -ForegroundColor White

if ($BaseUrl -like "*localhost*") {
    Write-Host "   Frontend: http://localhost:3000" -ForegroundColor White
}
