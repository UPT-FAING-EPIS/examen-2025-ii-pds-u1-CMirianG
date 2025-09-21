[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/A-aUFMBb)
[![Open in Codespaces](https://classroom.github.com/assets/launch-codespace-2972f46106e565e64193e422d61a12cf1da4916b45550586e14ef0a7c637dd04.svg)](https://classroom.github.com/open-in-codespaces?assignment_repo_id=20616762)
# Proyecto: Aplicación de Gestión de Asistencia a Cursos

## Objetivo
Desarrollar una plataforma web que permita registrar, monitorear y reportar la asistencia de estudiantes a cursos presenciales o virtuales, facilitando el control tanto para instructores como para administradores.

## Funcionalidades Principales
- Catálogo de cursos y grupos.
- Registro de asistencia por sesión (manual o mediante código QR/código único).
- Visualización de historial de asistencia por estudiante y por curso.
- Reportes de asistencia y alertas de inasistencia.

## Backend (API)
- Framework sugerido: .NET Core.
- Endpoints RESTful:
- `GET /courses` — Listar cursos disponibles.
- `GET /courses/{id}` — Detalle de curso.
- `POST /sessions` — Crear sesión de curso.
- `POST /attendance` — Registrar asistencia de estudiante.
- `GET /attendance?courseId={id}` — Ver asistencia por curso.
- `GET /attendance?studentId={id}` — Ver asistencia por estudiante.
- `GET /reports/attendance` — Reportes de asistencia.
- Base de datos relacional (ej: SQL Server, PostgreSQL).
- Pruebas unitarias y de integración.

## Frontend
- Framework sugerido: Angular, React o Vue.
- Funcionalidades:
- Panel de cursos y sesiones.
- Registro y visualización de asistencia.
- Panel de usuario para ver historial personal.
- Panel de instructor para tomar asistencia y ver reportes.

## Criterios de Evaluación
1. Calidad y organización del código, código limpio, principios de diseño aplicados.
2. Crear la infraestrutura utilizando IaC (Terraform).
3. Crear una automatización para para el despliegue de la infraestructura en Github (infra.yml)
4. Crear una automatizaciòn para generar el diagrama de infraestructura en el repositorio (infra_diagram.yml)
5. Crear una automatizaciòn para generar el diagrama de clases de la aplicaciòn (class_diagram.yml)
6. Crear una automatizaciòn para generar la documentaciòn del còdigo en Github Page (publish_doc.yml)
7. Creaciòn una automatizaciòn para realizar el escaneo de la aplicaciòn con SonarQube (sonar.yml) - 0 bugs, 0 vulnerabilidades, 0 hotspots, 90% de cobertura, 10 lineas de codigo duplicado
8. Crear una automatizaciòn para el despliegue del frontend y del backend (deploy_app.yml)
9. Crear una automatizaciòn para la creaciòn del release (release.yml)

## Final
1. Responder con la URL de la aplicaciòn desplegada
2. Responder con la URL del repositorio Github
