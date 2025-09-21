# Sistema de Asistencia Estudiantil

Una plataforma web moderna para registrar, monitorear y reportar la asistencia de estudiantes a cursos presenciales o virtuales.

## 🚀 Características

- **Gestión de Cursos**: Crear y administrar cursos con información detallada
- **Sesiones de Clase**: Programar sesiones con códigos únicos para registro de asistencia
- **Registro de Asistencia**: Sistema de códigos únicos de 6 dígitos para registro rápido
- **Portal del Estudiante**: Interfaz dedicada para que los estudiantes registren su asistencia
- **Reportes y Analytics**: Visualización de estadísticas y alertas de asistencia
- **Alertas Automáticas**: Notificaciones para estudiantes con baja asistencia

## 🛠 Tecnologías Utilizadas

### Backend
- **.NET 8.0** - Framework principal
- **Entity Framework Core** - ORM para base de datos
- **SQLite** - Base de datos (fácil configuración y portabilidad)
- **Swagger/OpenAPI** - Documentación de API

### Frontend
- **React 18** - Biblioteca de interfaz de usuario
- **TypeScript** - Tipado estático
- **Vite** - Herramienta de construcción rápida
- **Tailwind CSS** - Framework de estilos
- **Lucide React** - Iconos
- **Axios** - Cliente HTTP

## 📦 Estructura del Proyecto

```
├── backend/
│   └── AttendanceSystem.API/
│       ├── Controllers/         # Controladores de API
│       ├── Models/             # Modelos de datos
│       ├── Data/               # Contexto de base de datos
│       └── DTOs/               # Objetos de transferencia de datos
├── frontend/
│   └── src/
│       ├── components/         # Componentes React reutilizables
│       ├── pages/             # Páginas principales
│       ├── services/          # Servicios de API
│       └── types/             # Definiciones de tipos TypeScript
└── .github/workflows/         # Configuración CI/CD
```

## 🚦 Configuración y Ejecución

### Prerrequisitos
- .NET 8.0 SDK
- Node.js 18+
- Git

### Configuración del Backend

1. Navega al directorio del backend:
```bash
cd backend/AttendanceSystem.API
```

2. Restaura las dependencias:
```bash
dotnet restore
```

3. Ejecuta la aplicación:
```bash
dotnet run
```

La API estará disponible en `http://localhost:5000` y la documentación Swagger en `http://localhost:5000/swagger`

### Configuración del Frontend

1. Navega al directorio del frontend:
```bash
cd frontend
```

2. Instala las dependencias:
```bash
npm install
```

3. Ejecuta la aplicación en modo desarrollo:
```bash
npm run dev
```

La aplicación estará disponible en `http://localhost:3000`

## 📊 API Endpoints

### Cursos
- `GET /api/courses` - Listar todos los cursos
- `GET /api/courses/{id}` - Obtener curso por ID
- `POST /api/courses` - Crear nuevo curso
- `PUT /api/courses/{id}` - Actualizar curso
- `DELETE /api/courses/{id}` - Eliminar curso (soft delete)

### Sesiones
- `GET /api/sessions` - Listar sesiones (filtrable por curso)
- `GET /api/sessions/{id}` - Obtener sesión por ID
- `GET /api/sessions/by-code/{code}` - Obtener sesión por código único
- `POST /api/sessions` - Crear nueva sesión
- `PUT /api/sessions/{id}` - Actualizar sesión
- `DELETE /api/sessions/{id}` - Eliminar sesión

### Asistencia
- `POST /api/attendance` - Registrar asistencia
- `GET /api/attendance` - Obtener registros de asistencia (filtrable)
- `GET /api/attendance/{id}` - Obtener registro específico
- `GET /api/attendance/students` - Listar estudiantes

### Reportes
- `GET /api/reports/attendance` - Reportes de asistencia por curso
- `GET /api/reports/attendance/student/{id}` - Historial de estudiante
- `GET /api/reports/attendance/alerts` - Alertas de baja asistencia

## 🎯 Funcionalidades Principales

### Para Instructores
- Crear y gestionar cursos
- Programar sesiones de clase
- Generar códigos únicos para cada sesión
- Visualizar reportes de asistencia
- Recibir alertas de estudiantes con baja asistencia

### Para Estudiantes
- Registrar asistencia usando códigos de sesión
- Visualizar historial personal de asistencia
- Ver estadísticas de asistencia por curso

### Para Administradores
- Dashboard con métricas generales
- Reportes detallados de asistencia
- Gestión de alertas y umbrales
- Exportación de datos a CSV

## ☁️ Deployment en Azure

### Configuración para Azure for Students

1. **Backend (Azure App Service)**:
   - Crea un App Service en Azure Portal
   - Configura la publicación desde GitHub
   - Agrega el secreto `AZURE_WEBAPP_PUBLISH_PROFILE_API` en GitHub

2. **Frontend (Azure Static Web Apps)**:
   - Crea una Static Web App en Azure Portal
   - Conecta con tu repositorio de GitHub
   - Agrega el secreto `AZURE_STATIC_WEB_APPS_API_TOKEN` en GitHub

3. **Base de Datos**:
   - SQLite se incluye en el deployment
   - Para producción, considera migrar a Azure SQL Database

### Variables de Entorno

El proyecto está configurado para funcionar con las configuraciones por defecto. Para producción, actualiza:

- `appsettings.Production.json` para configuraciones del backend
- Variables de entorno en Azure App Service si es necesario

## 🔧 Desarrollo

### Comandos Útiles

**Backend**:
```bash
# Ejecutar con recarga automática
dotnet watch run

# Crear migración (si usas migraciones)
dotnet ef migrations add InitialCreate

# Actualizar base de datos
dotnet ef database update
```

**Frontend**:
```bash
# Desarrollo con recarga automática
npm run dev

# Build para producción
npm run build

# Previsualizar build de producción
npm run preview
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. Revisa la documentación de la API en `/swagger`
2. Verifica que ambos servicios (backend y frontend) estén ejecutándose
3. Revisa los logs de la consola para errores
4. Asegúrate de que las URLs de la API sean correctas en `services/api.ts`

## 🎉 ¡Listo para usar!

Tu sistema de asistencia estudiantil está configurado y listo para usar. El sistema incluye datos de prueba para que puedas comenzar a explorar inmediatamente.

**Datos de prueba incluidos**:
- 3 estudiantes de ejemplo
- 2 cursos de ejemplo
- Interfaz completamente funcional

¡Disfruta gestionando la asistencia de manera moderna y eficiente!