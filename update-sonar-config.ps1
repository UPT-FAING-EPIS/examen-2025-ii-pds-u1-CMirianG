# PowerShell script to update SonarQube configuration with personal GitHub account
# Usage: .\update-sonar-config.ps1 -GitHubUsername "tu-usuario"

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubUsername
)

Write-Host "🔧 Updating SonarQube configuration for user: $GitHubUsername" -ForegroundColor Green

# Update sonar-project.properties
Write-Host "📝 Updating sonar-project.properties..." -ForegroundColor Yellow
$sonarPropsPath = "sonar-project.properties"
if (Test-Path $sonarPropsPath) {
    $content = Get-Content $sonarPropsPath -Raw
    $content = $content -replace 'sonar\.organization=cmiriang', "sonar.organization=$GitHubUsername"
    Set-Content -Path $sonarPropsPath -Value $content
    Write-Host "✅ Updated sonar-project.properties" -ForegroundColor Green
} else {
    Write-Host "❌ sonar-project.properties not found" -ForegroundColor Red
}

# Update sonar.yml workflow
Write-Host "📝 Updating sonar.yml workflow..." -ForegroundColor Yellow
$sonarWorkflowPath = ".github\workflows\sonar.yml"
if (Test-Path $sonarWorkflowPath) {
    $content = Get-Content $sonarWorkflowPath -Raw
    $content = $content -replace '/o:"cmiriang"', "/o:`"$GitHubUsername`""
    Set-Content -Path $sonarWorkflowPath -Value $content
    Write-Host "✅ Updated sonar.yml workflow" -ForegroundColor Green
} else {
    Write-Host "❌ sonar.yml workflow not found" -ForegroundColor Red
}

# Update setup-sonar.yml workflow
Write-Host "📝 Updating setup-sonar.yml workflow..." -ForegroundColor Yellow
$setupWorkflowPath = ".github\workflows\setup-sonar.yml"
if (Test-Path $setupWorkflowPath) {
    $content = Get-Content $setupWorkflowPath -Raw
    $content = $content -replace 'cmiriang', $GitHubUsername
    Set-Content -Path $setupWorkflowPath -Value $content
    Write-Host "✅ Updated setup-sonar.yml workflow" -ForegroundColor Green
} else {
    Write-Host "❌ setup-sonar.yml workflow not found" -ForegroundColor Red
}

# Update documentation files
Write-Host "📝 Updating documentation..." -ForegroundColor Yellow

$docsToUpdate = @(
    "SONARQUBE_SETUP.md",
    "README_SONARQUBE.md",
    "SONARQUBE_ALTERNATIVAS.md"
)

foreach ($doc in $docsToUpdate) {
    if (Test-Path $doc) {
        $content = Get-Content $doc -Raw
        $content = $content -replace 'cmiriang', $GitHubUsername
        Set-Content -Path $doc -Value $content
        Write-Host "✅ Updated $doc" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "🎉 Configuration updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Go to https://sonarcloud.io" -ForegroundColor White
Write-Host "2. Login with your GitHub account ($GitHubUsername)" -ForegroundColor White
Write-Host "3. Create a new project" -ForegroundColor White
Write-Host "4. Import repository 'examen-2025-ii-pds-u1-CMirianG'" -ForegroundColor White
Write-Host "5. Generate a token in 'My Account' → 'Security'" -ForegroundColor White
Write-Host "6. Add token as 'SONAR_TOKEN' secret in GitHub repository" -ForegroundColor White
Write-Host ""
Write-Host "🔗 SonarCloud project URL will be:" -ForegroundColor Cyan
Write-Host "https://sonarcloud.io/project/overview?id=examen-2025-ii-pds-u1-CMirianG" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: The system works perfectly in local mode without SonarCloud!" -ForegroundColor Yellow
