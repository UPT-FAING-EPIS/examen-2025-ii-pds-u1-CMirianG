# Script para configurar la base de datos en Azure SQL
Write-Host "🗄️ CONFIGURANDO BASE DE DATOS EN AZURE SQL" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

# Configurar variables
$RESOURCE_GROUP = "attendance-system-rg"
$SQL_SERVER_NAME = "attendance-system-sqlserver"
$DATABASE_NAME = "attendance-system-db"
$ADMIN_USERNAME = "attendance-admin"
$ADMIN_PASSWORD = "AttendanceSystem2025!"
$APP_NAME = "assistenciaestudiantil-gefwbed2f7h8csd8"

Write-Host "📋 Configuración de la base de datos:" -ForegroundColor Yellow
Write-Host "   Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "   SQL Server: $SQL_SERVER_NAME" -ForegroundColor White
Write-Host "   Database: $DATABASE_NAME" -ForegroundColor White
Write-Host "   Admin Username: $ADMIN_USERNAME" -ForegroundColor White
Write-Host ""

# Verificar si el servidor SQL existe
Write-Host "🔍 Verificando servidor SQL..." -ForegroundColor Yellow
try {
    $sqlServer = az sql server show --name $SQL_SERVER_NAME --resource-group $RESOURCE_GROUP --output json 2>$null | ConvertFrom-Json
    Write-Host "✅ Servidor SQL encontrado: $($sqlServer.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Servidor SQL no encontrado. Creando nuevo servidor..." -ForegroundColor Yellow
    
    # Crear servidor SQL
    Write-Host "🏗️ Creando servidor SQL..." -ForegroundColor Yellow
    az sql server create `
        --name $SQL_SERVER_NAME `
        --resource-group $RESOURCE_GROUP `
        --location "canadacentral" `
        --admin-user $ADMIN_USERNAME `
        --admin-password $ADMIN_PASSWORD `
        --output none
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al crear el servidor SQL" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Servidor SQL creado exitosamente" -ForegroundColor Green
}

# Crear base de datos
Write-Host "🗄️ Verificando base de datos..." -ForegroundColor Yellow
try {
    $database = az sql db show --name $DATABASE_NAME --resource-group $RESOURCE_GROUP --server $SQL_SERVER_NAME --output json 2>$null | ConvertFrom-Json
    Write-Host "✅ Base de datos encontrada: $($database.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Base de datos no encontrada. Creando nueva base de datos..." -ForegroundColor Yellow
    
    # Crear base de datos
    Write-Host "🏗️ Creando base de datos..." -ForegroundColor Yellow
    az sql db create `
        --name $DATABASE_NAME `
        --resource-group $RESOURCE_GROUP `
        --server $SQL_SERVER_NAME `
        --service-objective "Basic" `
        --output none
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al crear la base de datos" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Base de datos creada exitosamente" -ForegroundColor Green
}

# Configurar firewall para permitir servicios de Azure
Write-Host "🔥 Configurando firewall..." -ForegroundColor Yellow
az sql server firewall-rule create `
    --resource-group $RESOURCE_GROUP `
    --server $SQL_SERVER_NAME `
    --name "AllowAzureServices" `
    --start-ip-address "0.0.0.0" `
    --end-ip-address "0.0.0.0" `
    --output none

Write-Host "✅ Regla de firewall configurada" -ForegroundColor Green

# Configurar cadena de conexión
$CONNECTION_STRING = "Server=tcp:$SQL_SERVER_NAME.database.windows.net,1433;Initial Catalog=$DATABASE_NAME;Persist Security Info=False;User ID=$ADMIN_USERNAME;Password=$ADMIN_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

Write-Host "🔗 Configurando cadena de conexión en Azure App Service..." -ForegroundColor Yellow

# Configurar la cadena de conexión en Azure App Service
az webapp config connection-string set `
    --resource-group $RESOURCE_GROUP `
    --name $APP_NAME `
    --connection-string-type "SQLServer" `
    --settings "DefaultConnection=$CONNECTION_STRING" `
    --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al configurar la cadena de conexión" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Cadena de conexión configurada en Azure App Service" -ForegroundColor Green

# Configurar variables de entorno
Write-Host "⚙️ Configurando variables de entorno..." -ForegroundColor Yellow
az webapp config appsettings set `
    --resource-group $RESOURCE_GROUP `
    --name $APP_NAME `
    --settings "ASPNETCORE_ENVIRONMENT=Production" `
    --output none

Write-Host "✅ Variables de entorno configuradas" -ForegroundColor Green

Write-Host ""
Write-Host "🎉 ¡BASE DE DATOS CONFIGURADA EXITOSAMENTE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Información de la base de datos:" -ForegroundColor White
Write-Host "   🗄️ Servidor: $SQL_SERVER_NAME.database.windows.net" -ForegroundColor Cyan
Write-Host "   📊 Base de datos: $DATABASE_NAME" -ForegroundColor Cyan
Write-Host "   👤 Usuario: $ADMIN_USERNAME" -ForegroundColor Cyan
Write-Host "   🔗 Cadena de conexión: Configurada en Azure App Service" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ La base de datos está lista para usar!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Reiniciar la aplicación en Azure" -ForegroundColor White
Write-Host "   2. Las tablas se crearán automáticamente con Entity Framework" -ForegroundColor White
Write-Host "   3. Probar la aplicación" -ForegroundColor White
