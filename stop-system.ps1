# Script simple para detener el Attendance System
Write-Host "Deteniendo Attendance System..." -ForegroundColor Red

Get-Job | Stop-Job
Get-Job | Remove-Job

Write-Host "Sistema detenido!" -ForegroundColor Green
