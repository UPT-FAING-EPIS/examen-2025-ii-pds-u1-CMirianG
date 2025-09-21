#!/bin/bash
# Bash script to update SonarQube configuration with personal GitHub account
# Usage: ./update-sonar-config.sh tu-usuario

if [ $# -eq 0 ]; then
    echo "❌ Error: GitHub username required"
    echo "Usage: ./update-sonar-config.sh tu-usuario"
    exit 1
fi

GITHUB_USERNAME=$1

echo "🔧 Updating SonarQube configuration for user: $GITHUB_USERNAME"

# Update sonar-project.properties
echo "📝 Updating sonar-project.properties..."
if [ -f "sonar-project.properties" ]; then
    sed -i.bak "s/sonar\.organization=cmiriang/sonar.organization=$GITHUB_USERNAME/g" sonar-project.properties
    echo "✅ Updated sonar-project.properties"
else
    echo "❌ sonar-project.properties not found"
fi

# Update sonar.yml workflow
echo "📝 Updating sonar.yml workflow..."
if [ -f ".github/workflows/sonar.yml" ]; then
    sed -i.bak "s|/o:\"cmiriang\"|/o:\"$GITHUB_USERNAME\"|g" .github/workflows/sonar.yml
    echo "✅ Updated sonar.yml workflow"
else
    echo "❌ sonar.yml workflow not found"
fi

# Update setup-sonar.yml workflow
echo "📝 Updating setup-sonar.yml workflow..."
if [ -f ".github/workflows/setup-sonar.yml" ]; then
    sed -i.bak "s/cmiriang/$GITHUB_USERNAME/g" .github/workflows/setup-sonar.yml
    echo "✅ Updated setup-sonar.yml workflow"
else
    echo "❌ setup-sonar.yml workflow not found"
fi

# Update documentation files
echo "📝 Updating documentation..."
docs=("SONARQUBE_SETUP.md" "README_SONARQUBE.md" "SONARQUBE_ALTERNATIVAS.md")

for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        sed -i.bak "s/cmiriang/$GITHUB_USERNAME/g" "$doc"
        echo "✅ Updated $doc"
    fi
done

# Clean up backup files
find . -name "*.bak" -delete

echo ""
echo "🎉 Configuration updated successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Go to https://sonarcloud.io"
echo "2. Login with your GitHub account ($GITHUB_USERNAME)"
echo "3. Create a new project"
echo "4. Import repository 'examen-2025-ii-pds-u1-CMirianG'"
echo "5. Generate a token in 'My Account' → 'Security'"
echo "6. Add token as 'SONAR_TOKEN' secret in GitHub repository"
echo ""
echo "🔗 SonarCloud project URL will be:"
echo "https://sonarcloud.io/project/overview?id=examen-2025-ii-pds-u1-CMirianG"
echo ""
echo "💡 Tip: The system works perfectly in local mode without SonarCloud!"
