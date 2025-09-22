# 🏠 Despliegue Local - Attendance System

Esta guía te permite ejecutar el sistema completo localmente con una base de datos en línea.

## 🚀 Inicio Rápido (3 pasos)

### 1. Configurar Base de Datos
```powershell
.\setup-database.ps1
```

### 2. Desplegar Sistema
```powershell
.\deploy-local.ps1
```

### 3. Iniciar Todo
```powershell
.\start-all.ps1
```

## 📋 Prerrequisitos

- ✅ .NET 8.0 SDK
- ✅ Node.js 18+
- ✅ Azure CLI (para base de datos)
- ✅ PowerShell 5.0+

## 🗄️ Configuración de Base de Datos

### Opción A: Crear nueva base de datos (Recomendado)
```powershell
.\setup-database.ps1
```

Este script:
- ✅ Crea Resource Group en Azure
- ✅ Crea SQL Server
- ✅ Crea Database
- ✅ Configura firewall
- ✅ Actualiza appsettings.json automáticamente

### Opción B: Usar base de datos existente
1. Edita `backend\AttendanceSystem.API\appsettings.json`
2. Actualiza la connection string
3. Continúa con el despliegue

## 🏗️ Arquitectura Local

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend       │    │   Azure SQL     │
│   React + Vite  │◄──►│   .NET 8 API     │◄──►│   Database      │
│   :3000         │    │   :5000          │    │   (Cloud)       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📁 Scripts Disponibles

### Scripts Principales
- **`setup-database.ps1`** - Configura base de datos Azure SQL
- **`deploy-local.ps1`** - Prepara el sistema (build, install)
- **`start-all.ps1`** - Inicia todo el sistema
- **`stop-all.ps1`** - Detiene todo el sistema

### Scripts Individuales
- **`start-backend.ps1`** - Solo backend
- **`start-frontend.ps1`** - Solo frontend

## 🌐 URLs del Sistema

Una vez iniciado:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **Swagger UI**: http://localhost:5000/swagger
- **Health Check**: http://localhost:5000/health

## 🔧 Configuración Manual

### Backend
```powershell
cd backend\AttendanceSystem.API
dotnet restore
dotnet build
dotnet run --urls="http://localhost:5000"
```

### Frontend
```powershell
cd frontend
npm install
npm run dev -- --port 3000
```

## 📊 Monitoreo

### Ver logs en tiempo real
```powershell
# Si usaste start-all.ps1
Receive-Job -Id <JobID>
```

### Verificar estado
```powershell
# Backend
curl http://localhost:5000/health

# Frontend
curl http://localhost:3000
```

## 🗄️ Base de Datos

### Connection String
El sistema usa Azure SQL Database con la siguiente configuración:
- **Server**: `attendance-system-sqlserver.database.windows.net`
- **Database**: `attendance-system-db`
- **Usuario**: `sqladmin`
- **Password**: Configurado automáticamente

### Estructura de Tablas
El sistema crea automáticamente:
- `Students` - Estudiantes
- `Courses` - Cursos
- `Sessions` - Sesiones
- `Attendance` - Asistencia

### Datos de Prueba
El sistema incluye datos de ejemplo:
- 3 estudiantes
- 2 cursos
- 2 sesiones para hoy

## 🔍 Troubleshooting

### Error: "Cannot connect to database"
1. Verifica que la base de datos existe en Azure
2. Verifica la connection string en appsettings.json
3. Verifica que el firewall permite tu IP

### Error: "Port already in use"
```powershell
# Verificar procesos
netstat -ano | findstr :5000
netstat -ano | findstr :3000

# Detener todo
.\stop-all.ps1
```

### Error: "Azure CLI not found"
1. Instala Azure CLI desde: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
2. Ejecuta: `az login`

### Error: "Node modules not found"
```powershell
cd frontend
npm install
```

### Error: "Dotnet restore failed"
```powershell
cd backend\AttendanceSystem.API
dotnet restore --force
```

## 💰 Costos

### Azure SQL Database
- **Basic tier**: ~$5/mes
- **Puedes detener**: Scripts para pausar/reanudar
- **Solo pagas**: Cuando está activo

### Alternativas gratuitas
- SQL Server Local (gratis)
- SQLite (gratis)
- PostgreSQL Local (gratis)

## 🔒 Seguridad

### Desarrollo
- ✅ Firewall configurado para desarrollo
- ✅ Connection strings en archivos de configuración
- ✅ No credenciales en código

### Producción
- ⚠️ Cambiar passwords por defecto
- ⚠️ Configurar firewall específico
- ⚠️ Usar Azure Key Vault

## 📱 Funcionalidades Disponibles

### Frontend (React)
- ✅ Dashboard principal
- ✅ Gestión de estudiantes
- ✅ Gestión de cursos
- ✅ Gestión de sesiones
- ✅ Registro de asistencia
- ✅ Reportes

### Backend (API)
- ✅ RESTful API completa
- ✅ Swagger documentation
- ✅ Entity Framework Core
- ✅ Repository pattern
- ✅ CORS configurado

### Base de Datos
- ✅ Azure SQL Database
- ✅ Tablas automáticamente creadas
- ✅ Datos de ejemplo
- ✅ Relaciones configuradas

## 🎯 Próximos Pasos

1. **Explorar la aplicación**: Navega por todas las funcionalidades
2. **Probar APIs**: Usa Swagger UI para probar endpoints
3. **Personalizar**: Modifica el código según tus necesidades
4. **Desplegar**: Cuando esté listo, despliega a Azure

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs en la consola
2. Verifica que todos los prerrequisitos están instalados
3. Revisa la configuración de la base de datos
4. Consulta los archivos de log

---

**¡Disfruta desarrollando con tu sistema local!** 🎉
