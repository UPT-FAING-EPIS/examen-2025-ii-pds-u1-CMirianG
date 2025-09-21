# 🧪 PRUEBAS DE FUNCIONAMIENTO COMPLETAS

## 🎯 **PRUEBAS PARA SISTEMA LOCAL**

### **1. Verificar Backend (API)**

#### **Health Check:**
```powershell
curl http://localhost:5000/health
# Resultado esperado: "OK"
```

#### **Swagger Documentation:**
```powershell
start http://localhost:5000/swagger
# Debe abrir página con documentación de API
```

#### **API Endpoints:**
```powershell
# Obtener cursos
curl http://localhost:5000/api/courses

# Obtener estudiantes
curl http://localhost:5000/api/attendance/students

# Obtener sesiones
curl http://localhost:5000/api/sessions
```

### **2. Verificar Frontend (React)**

#### **Aplicación Principal:**
```powershell
start http://localhost:3000
# Debe abrir la aplicación React
```

#### **Páginas a verificar:**
- ✅ **Dashboard** - Estadísticas generales
- ✅ **Cursos** - Lista de cursos (debe mostrar 2 cursos de ejemplo)
- ✅ **Sesiones** - Gestión de sesiones
- ✅ **Asistencia** - Registros de asistencia
- ✅ **Reportes** - Analytics y reportes
- ✅ **Portal Estudiante** - Registro de asistencia

### **3. Verificar Base de Datos**

#### **Verificar archivo SQLite:**
```powershell
ls backend\AttendanceSystem.API\attendance.db
# Debe existir el archivo (aproximadamente 50KB)
```

#### **Verificar datos de prueba:**
- **Estudiantes**: Juan Pérez, María González, Carlos Rodríguez
- **Cursos**: Programación Web (PW001), Base de Datos (BD001)

## 🌐 **PRUEBAS PARA SISTEMA EN AZURE**

### **1. Verificar Backend en Azure**

#### **Health Check:**
```powershell
start http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net/health
# Resultado esperado: "OK"
```

#### **Swagger Documentation:**
```powershell
start http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net/swagger
# Debe mostrar documentación completa de API
```

#### **API Endpoints en Azure:**
```powershell
# Obtener cursos
curl http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net/api/courses

# Obtener estudiantes
curl http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net/api/attendance/students

# Obtener reportes
curl http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net/api/reports/attendance
```

### **2. Verificar Base de Datos en Azure**

#### **Verificar conexión:**
La base de datos SQLite funciona automáticamente en Azure App Service.

#### **Verificar datos:**
- Los datos de prueba se crean automáticamente al iniciar la aplicación

## 🔧 **PRUEBAS FUNCIONALES COMPLETAS**

### **Prueba 1: Gestión de Cursos**

#### **Crear nuevo curso:**
```json
POST http://localhost:5000/api/courses
Content-Type: application/json

{
  "name": "Prueba de Curso",
  "code": "TEST001",
  "description": "Curso de prueba para verificar funcionamiento",
  "instructorName": "Instructor de Prueba"
}
```

#### **Verificar curso creado:**
```powershell
curl http://localhost:5000/api/courses
# Debe aparecer el nuevo curso en la lista
```

### **Prueba 2: Gestión de Sesiones**

#### **Crear nueva sesión:**
```json
POST http://localhost:5000/api/sessions
Content-Type: application/json

{
  "courseId": 1,
  "title": "Sesión de Prueba",
  "date": "2024-01-15T00:00:00Z",
  "startTime": "10:00:00",
  "endTime": "11:30:00"
}
```

#### **Verificar código único generado:**
- La respuesta debe incluir un `uniqueCode` de 6 dígitos

### **Prueba 3: Registro de Asistencia**

#### **Registrar asistencia:**
```json
POST http://localhost:5000/api/attendance
Content-Type: application/json

{
  "studentId": 1,
  "sessionCode": "123456",
  "notes": "Presente a tiempo"
}
```

#### **Verificar asistencia registrada:**
```powershell
curl http://localhost:5000/api/attendance?studentId=1
# Debe mostrar el registro de asistencia
```

### **Prueba 4: Reportes y Analytics**

#### **Obtener reporte de asistencia:**
```powershell
curl http://localhost:5000/api/reports/attendance
# Debe mostrar estadísticas por curso
```

#### **Obtener alertas:**
```powershell
curl http://localhost:5000/api/reports/attendance/alerts?threshold=70
# Debe mostrar estudiantes con baja asistencia
```

## 🎮 **PRUEBAS DE INTERFAZ (Frontend)**

### **Prueba 1: Dashboard**
- ✅ Verifica que se muestren estadísticas
- ✅ Verifica cards con números
- ✅ Verifica sesiones recientes
- ✅ Verifica alertas de asistencia

### **Prueba 2: Portal Estudiante**
- ✅ Seleccionar estudiante
- ✅ Ingresar código de sesión
- ✅ Registrar asistencia
- ✅ Ver historial personal

### **Prueba 3: Gestión de Cursos**
- ✅ Ver lista de cursos
- ✅ Crear nuevo curso
- ✅ Editar curso existente
- ✅ Ver detalles del curso

### **Prueba 4: Reportes**
- ✅ Ver reportes por curso
- ✅ Exportar a CSV
- ✅ Ver alertas de inasistencia
- ✅ Filtrar por curso

## 🚀 **SCRIPT DE PRUEBAS AUTOMATIZADO**
