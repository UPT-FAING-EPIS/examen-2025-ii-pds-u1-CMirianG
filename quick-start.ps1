# PowerShell script para inicio rápido completo
# Usage: .\quick-start.ps1

Write-Host "🚀 Attendance System - Inicio Rápido" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Verificar prerrequisitos
Write-Host ""
Write-Host "🔍 Verificando prerrequisitos..." -ForegroundColor Cyan

$prerequisitesOK = $true

# Verificar .NET
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ .NET 8 SDK no encontrado" -ForegroundColor Red
    $prerequisitesOK = $false
}

# Verificar Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js no encontrado" -ForegroundColor Red
    $prerequisitesOK = $false
}

# Verificar Azure CLI
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Azure CLI no encontrado (opcional para BD local)" -ForegroundColor Yellow
}

if (-not $prerequisitesOK) {
    Write-Host ""
    Write-Host "❌ Prerrequisitos faltantes. Instálalos antes de continuar." -ForegroundColor Red
    Write-Host "• .NET 8 SDK: https://dotnet.microsoft.com/download" -ForegroundColor White
    Write-Host "• Node.js: https://nodejs.org/" -ForegroundColor White
    Write-Host "• Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "📋 Opciones de configuración:" -ForegroundColor Cyan
Write-Host "1. Configuración completa (Base de datos Azure SQL + Sistema local)" -ForegroundColor White
Write-Host "2. Solo sistema local (Base de datos existente)" -ForegroundColor White
Write-Host "3. Solo verificar sistema existente" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Selecciona una opción (1-3)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🏗️ Configuración completa seleccionada..." -ForegroundColor Green
        
        # Preguntar si quiere crear nueva BD
        $createDB = Read-Host "¿Crear nueva base de datos Azure SQL? (s/n)"
        if ($createDB -eq "s" -or $createDB -eq "S" -or $createDB -eq "y" -or $createDB -eq "Y") {
            Write-Host "🗄️ Configurando base de datos..." -ForegroundColor Yellow
            .\setup-database.ps1
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ Error configurando base de datos" -ForegroundColor Red
                exit 1
            }
        }
        
        # Desplegar sistema
        Write-Host "📦 Desplegando sistema..." -ForegroundColor Yellow
        .\deploy-local.ps1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error desplegando sistema" -ForegroundColor Red
            exit 1
        }
        
        # Iniciar sistema
        Write-Host "🏃 Iniciando sistema..." -ForegroundColor Yellow
        .\start-all.ps1
    }
    
    "2" {
        Write-Host ""
        Write-Host "📦 Solo sistema local seleccionado..." -ForegroundColor Green
        
        # Verificar configuración de BD
        $appsettingsPath = "backend\AttendanceSystem.API\appsettings.json"
        if (-not (Test-Path $appsettingsPath)) {
            Write-Host "❌ appsettings.json no encontrado" -ForegroundColor Red
            exit 1
        }
        
        $config = Get-Content $appsettingsPath | ConvertFrom-Json
        if (-not $config.ConnectionStrings.DefaultConnection) {
            Write-Host "⚠️ Connection string no configurada. Configura la base de datos primero." -ForegroundColor Yellow
            exit 1
        }
        
        # Desplegar sistema
        Write-Host "📦 Desplegando sistema..." -ForegroundColor Yellow
        .\deploy-local.ps1
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error desplegando sistema" -ForegroundColor Red
            exit 1
        }
        
        # Iniciar sistema
        Write-Host "🏃 Iniciando sistema..." -ForegroundColor Yellow
        .\start-all.ps1
    }
    
    "3" {
        Write-Host ""
        Write-Host "🧪 Verificando sistema existente..." -ForegroundColor Green
        .\test-local-system.ps1
    }
    
    default {
        Write-Host "❌ Opción inválida" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🎉 ¡Proceso completado!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 URLs del sistema:" -ForegroundColor Cyan
Write-Host "• Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "• Backend API: http://localhost:5000" -ForegroundColor White
Write-Host "• Swagger UI: http://localhost:5000/swagger" -ForegroundColor White
Write-Host ""
Write-Host "📝 Comandos útiles:" -ForegroundColor Cyan
Write-Host "• Detener sistema: .\stop-all.ps1" -ForegroundColor White
Write-Host "• Probar sistema: .\test-local-system.ps1" -ForegroundColor White
Write-Host "• Ver logs: Get-Job | Receive-Job" -ForegroundColor White
Write-Host ""
Write-Host "📚 Documentación:" -ForegroundColor Cyan
Write-Host "• Despliegue local: README_LOCAL_DEPLOYMENT.md" -ForegroundColor White
Write-Host "• Guía completa: LOCAL_DEPLOYMENT_GUIDE.md" -ForegroundColor White
