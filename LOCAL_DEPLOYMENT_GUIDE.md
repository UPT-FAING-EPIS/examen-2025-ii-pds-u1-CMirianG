# 🚀 Guía de Despliegue Local - Attendance System

Esta guía te ayudará a desplegar el sistema localmente con una base de datos en línea (Azure SQL).

## 📋 Prerrequisitos

- .NET 8.0 SDK
- Node.js 18+
- SQL Server Management Studio (opcional)
- Azure CLI (para conexión a BD)

## 🏗️ Arquitectura del Despliegue

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend       │    │   Azure SQL     │
│   (React)       │◄──►│   (.NET API)     │◄──►│   Database      │
│   localhost:3000│    │   localhost:5000 │    │   (Cloud)       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🔧 Paso 1: Configurar Base de Datos

### Opción A: Usar Azure SQL existente

Si ya tienes la infraestructura desplegada:

1. **Obtener connection string**:
   ```bash
   # Desde Azure Portal o Terraform outputs
   Server=tcp:tu-servidor.database.windows.net,1433;Initial Catalog=tu-db;User ID=tu-usuario;Password=tu-password;Encrypt=True;
   ```

### Opción B: Crear nueva base de datos

1. **Crear Resource Group**:
   ```bash
   az group create --name attendance-local-rg --location eastus
   ```

2. **Crear SQL Server**:
   ```bash
   az sql server create --name attendance-sql-local --resource-group attendance-local-rg --location eastus --admin-user sqladmin --admin-password "TuPassword123!"
   ```

3. **Crear Database**:
   ```bash
   az sql db create --resource-group attendance-local-rg --server attendance-sql-local --name attendance-local-db --service-objective Basic
   ```

4. **Configurar firewall** (para tu IP):
   ```bash
   az sql server firewall-rule create --resource-group attendance-local-rg --server attendance-sql-local --name AllowMyIP --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255
   ```

## 🔧 Paso 2: Configurar Backend

### 1. Actualizar appsettings.json

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:tu-servidor.database.windows.net,1433;Initial Catalog=tu-db;User ID=tu-usuario;Password=tu-password;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

### 2. Configurar Entity Framework

El sistema usará Azure SQL en lugar de InMemory.

## 🔧 Paso 3: Configurar Frontend

### 1. Actualizar API URL

El frontend se conectará al backend local en lugar del servidor remoto.

## 🔧 Paso 4: Scripts de Despliegue

Crearemos scripts para automatizar el proceso.

## 🔧 Paso 5: Verificación

- ✅ Backend corriendo en localhost:5000
- ✅ Frontend corriendo en localhost:3000
- ✅ Base de datos conectada y funcionando
- ✅ Swagger UI accesible
- ✅ Sistema completamente funcional

## 📊 Beneficios de este Despliegue

- ✅ **Desarrollo local**: Modifica código y ve cambios inmediatamente
- ✅ **Base de datos real**: Usa Azure SQL para datos persistentes
- ✅ **Debugging completo**: Puedes debuggear tanto frontend como backend
- ✅ **Sin costos de App Service**: Solo pagas por la base de datos
- ✅ **Control total**: Tienes control completo del entorno

---

**Próximo paso**: Configurar los archivos de configuración
