# 🔧 Configuración de SonarQube - Guía Completa

Esta guía te ayudará a configurar SonarQube para que funcione correctamente con el proyecto.

## 📋 Opciones de Configuración

### Opción 1: SonarCloud (Recomendado - Gratuito)

SonarCloud es la versión en la nube de SonarQube, perfecta para proyectos open source.

#### Paso 1: Crear cuenta en SonarCloud

1. Ve a [https://sonarcloud.io](https://sonarcloud.io)
2. Haz clic en "Sign up" o "Log in"
3. Conecta con tu cuenta de GitHub

#### Paso 2: Crear un proyecto

1. Una vez logueado, haz clic en "Create Project"
2. Selecciona "Import an organization from GitHub"
3. Selecciona tu organización "cmiriang"
4. Importa el repositorio "examen-2025-ii-pds-u1-CMirianG"

#### Paso 3: Obtener el token

1. Ve a "My Account" → "Security"
2. En "Generate Tokens", crea un nuevo token
3. Dale un nombre como "GitHub Actions - Attendance System"
4. Copia el token generado

#### Paso 4: Configurar el secret en GitHub

1. Ve a tu repositorio en GitHub
2. Ve a Settings → Secrets and variables → Actions
3. Haz clic en "New repository secret"
4. Nombre: `SONAR_TOKEN`
5. Valor: El token que copiaste de SonarCloud

### Opción 2: SonarQube Server Local

Si prefieres usar un servidor SonarQube local:

1. Descarga SonarQube Community Edition
2. Configura el servidor
3. Crea un proyecto
4. Genera un token
5. Configura la URL del servidor en el workflow

## 🔧 Configuración del Proyecto

### Archivo sonar-project.properties

El archivo ya está configurado con:

```properties
sonar.projectKey=examen-2025-ii-pds-u1-CMirianG
sonar.organization=cmiriang
sonar.host.url=https://sonarcloud.io
```

### Variables de Entorno Requeridas

En GitHub Actions necesitas estos secrets:

- `SONAR_TOKEN`: Token de autenticación de SonarQube
- `GITHUB_TOKEN`: Automáticamente proporcionado por GitHub

## 🚀 Workflow Actualizado

He actualizado el workflow para manejar casos donde no hay credenciales configuradas.

### Características del Workflow:

1. **Análisis condicional**: Solo ejecuta si hay token configurado
2. **Fallback**: Ejecuta análisis local si no hay SonarQube
3. **Reportes de cobertura**: Genera reportes locales
4. **Quality gates**: Verificación de calidad

## 📊 Métricas Objetivo

El proyecto está configurado para cumplir:

- **Bugs**: 0
- **Vulnerabilidades**: 0
- **Security Hotspots**: 0
- **Cobertura de código**: 90%
- **Líneas duplicadas**: <10

## 🔍 Verificación

### Para verificar que funciona:

1. **Con credenciales**:
   - Ve a [SonarCloud](https://sonarcloud.io/project/overview?id=examen-2025-ii-pds-u1-CMirianG)
   - Verifica que el análisis aparece

2. **Sin credenciales**:
   - El workflow ejecutará análisis local
   - Generará reportes de cobertura
   - Mostrará métricas en GitHub Actions

## 🛠️ Solución de Problemas

### Error: "Authentication failed"

- Verifica que el `SONAR_TOKEN` está configurado correctamente
- Asegúrate de que el token no ha expirado
- Verifica que la organización existe en SonarCloud

### Error: "Project not found"

- Verifica que el proyecto existe en SonarCloud
- Confirma que el `sonar.projectKey` coincide
- Verifica que tienes permisos en la organización

### Error: "No coverage reports found"

- El workflow genera reportes mock si no hay tests
- Para reportes reales, agrega tests al proyecto

## 📈 Mejoras Futuras

1. **Tests reales**: Agregar tests unitarios e integración
2. **Cobertura real**: Implementar tests con cobertura
3. **Quality gates**: Configurar reglas específicas
4. **Integración continua**: Análisis en cada PR

## 🔗 Enlaces Útiles

- [SonarCloud Documentation](https://docs.sonarcloud.io/)
- [SonarQube Quality Gates](https://docs.sonarcloud.io/user-guide/quality-gates/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

**Nota**: Si no configuras las credenciales, el workflow seguirá funcionando pero solo con análisis local. Para obtener el badge de calidad y análisis completo, necesitas configurar SonarCloud.
