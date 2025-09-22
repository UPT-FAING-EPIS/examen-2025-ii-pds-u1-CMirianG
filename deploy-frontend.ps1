# Script para desplegar frontend a GitHub Pages
Write-Host "DESPLEGANDO FRONTEND A GITHUB PAGES" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Ir al directorio frontend
Set-Location frontend

# Verificar que existe la carpeta dist
if (-not (Test-Path "dist")) {
    Write-Host "Error: No se encontro la carpeta dist. Ejecutando build..." -ForegroundColor Yellow
    npm run build
}

# Crear carpeta gh-pages si no existe
if (-not (Test-Path "../gh-pages")) {
    Write-Host "Creando carpeta gh-pages..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "../gh-pages"
}

# Copiar archivos de dist a gh-pages
Write-Host "Copiando archivos de build..." -ForegroundColor Yellow
Copy-Item -Path "dist/*" -Destination "../gh-pages/" -Recurse -Force

# Volver al directorio raiz
Set-Location ..

# Agregar archivos a git
Write-Host "Agregando archivos a git..." -ForegroundColor Yellow
git add gh-pages/

# Commit
Write-Host "Haciendo commit..." -ForegroundColor Yellow
git commit -m "Deploy frontend to GitHub Pages"

# Push
Write-Host "Subiendo a GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host ""
Write-Host "FRONTEND DESPLEGADO!" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host ""
Write-Host "Tu frontend estara disponible en:" -ForegroundColor White
Write-Host "https://cmiriang.github.io/examen-2025-ii-pds-u1-CMirianG/" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend API:" -ForegroundColor White
Write-Host "http://asistenciaestudiantil-gefwbed2f7h8csd8.canadacentral-01.azurewebsites.net" -ForegroundColor Cyan
