# PowerShell script para configurar la base de datos Azure SQL
# Usage: .\setup-database.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "attendance-local-rg",
    
    [Parameter(Mandatory=$false)]
    [string]$ServerName = "attendance-sql-local",
    
    [Parameter(Mandatory=$false)]
    [string]$DatabaseName = "attendance-local-db",
    
    [Parameter(Mandatory=$false)]
    [string]$AdminUsername = "sqladmin",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "eastus"
)

Write-Host "🗄️ Configurando base de datos Azure SQL..." -ForegroundColor Green

# Verificar Azure CLI
try {
    $azVersion = az version --output json | ConvertFrom-Json
    Write-Host "✅ Azure CLI Version: $($azVersion.'azure-cli')" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI no encontrado. Instálalo desde: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" -ForegroundColor Red
    exit 1
}

# Verificar login en Azure
try {
    $account = az account show --output json | ConvertFrom-Json
    Write-Host "✅ Logged in as: $($account.user.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ No estás logueado en Azure. Ejecuta: az login" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Configuración:" -ForegroundColor Cyan
Write-Host "• Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host "• Server Name: $ServerName" -ForegroundColor White
Write-Host "• Database Name: $DatabaseName" -ForegroundColor White
Write-Host "• Admin Username: $AdminUsername" -ForegroundColor White
Write-Host "• Location: $Location" -ForegroundColor White
Write-Host ""

# Crear Resource Group
Write-Host "🏗️ Creando Resource Group..." -ForegroundColor Yellow
az group create --name $ResourceGroupName --location $Location

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error creando Resource Group" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Resource Group creado" -ForegroundColor Green

# Generar password seguro
$password = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 12 | % {[char]$_})
Write-Host "🔐 Password generado para el servidor SQL" -ForegroundColor Yellow

# Crear SQL Server
Write-Host "🏗️ Creando SQL Server..." -ForegroundColor Yellow
az sql server create `
    --name $ServerName `
    --resource-group $ResourceGroupName `
    --location $Location `
    --admin-user $AdminUsername `
    --admin-password $password

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error creando SQL Server" -ForegroundColor Red
    exit 1
}

Write-Host "✅ SQL Server creado" -ForegroundColor Green

# Crear Database
Write-Host "🏗️ Creando Database..." -ForegroundColor Yellow
az sql db create `
    --resource-group $ResourceGroupName `
    --server $ServerName `
    --name $DatabaseName `
    --service-objective Basic

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error creando Database" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Database creado" -ForegroundColor Green

# Configurar firewall para permitir acceso desde cualquier IP
Write-Host "🔥 Configurando firewall..." -ForegroundColor Yellow
az sql server firewall-rule create `
    --resource-group $ResourceGroupName `
    --server $ServerName `
    --name "AllowAllIPs" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 255.255.255.255

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Advertencia: Error configurando firewall" -ForegroundColor Yellow
}

Write-Host "✅ Firewall configurado" -ForegroundColor Green

# Obtener información del servidor
Write-Host "📊 Obteniendo información del servidor..." -ForegroundColor Yellow
$serverInfo = az sql server show --name $ServerName --resource-group $ResourceGroupName --output json | ConvertFrom-Json

$connectionString = "Server=tcp:$($serverInfo.fullyQualifiedDomainName),1433;Initial Catalog=$DatabaseName;Persist Security Info=False;User ID=$AdminUsername;Password=$password;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host ""
Write-Host "🎉 ¡Base de datos configurada exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Información de la base de datos:" -ForegroundColor Cyan
Write-Host "• Server: $($serverInfo.fullyQualifiedDomainName)" -ForegroundColor White
Write-Host "• Database: $DatabaseName" -ForegroundColor White
Write-Host "• Username: $AdminUsername" -ForegroundColor White
Write-Host "• Password: $password" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Connection String:" -ForegroundColor Cyan
Write-Host $connectionString -ForegroundColor White
Write-Host ""

# Actualizar appsettings.json
Write-Host "📝 Actualizando appsettings.json..." -ForegroundColor Yellow
$appsettingsPath = "backend\AttendanceSystem.API\appsettings.json"

if (Test-Path $appsettingsPath) {
    $appsettings = Get-Content $appsettingsPath | ConvertFrom-Json
    $appsettings.ConnectionStrings.DefaultConnection = $connectionString
    $appsettings | ConvertTo-Json -Depth 10 | Set-Content $appsettingsPath
    Write-Host "✅ appsettings.json actualizado" -ForegroundColor Green
} else {
    Write-Host "⚠️ appsettings.json no encontrado en $appsettingsPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Ejecuta: .\deploy-local.ps1" -ForegroundColor White
Write-Host "2. Ejecuta: .\start-all.ps1" -ForegroundColor White
Write-Host "3. Abre: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "💡 Guarda la información de la base de datos en un lugar seguro" -ForegroundColor Yellow
