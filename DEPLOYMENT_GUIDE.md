# Deployment Guide - Attendance System

This guide provides step-by-step instructions for deploying the Attendance System to Azure.

## Prerequisites

Before deploying, ensure you have:

- Azure CLI installed and configured
- Terraform installed (version 1.6.0 or later)
- .NET 8.0 SDK
- Node.js 18+
- Git

## Deployment Steps

### 1. Infrastructure Deployment

The infrastructure is deployed using Terraform with GitHub Actions automation.

#### Manual Infrastructure Deployment

```bash
# Navigate to infrastructure directory
cd infrastructure

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply
```

#### Automated Infrastructure Deployment

The infrastructure is automatically deployed when changes are pushed to the `main` branch in the `infrastructure/` directory.

### 2. Application Deployment

#### Backend Deployment

The backend is automatically deployed to Azure App Service when changes are pushed to the `main` branch.

**Manual Backend Deployment:**

```bash
# Navigate to backend directory
cd backend/AttendanceSystem.API

# Restore dependencies
dotnet restore

# Build the application
dotnet build --configuration Release

# Publish the application
dotnet publish --configuration Release --output ./publish

# Deploy to Azure App Service using Azure CLI
az webapp deployment source config-zip \
  --resource-group <resource-group-name> \
  --name <app-service-name> \
  --src ./publish.zip
```

#### Frontend Deployment

The frontend is automatically deployed to Azure Static Web Apps when changes are pushed to the `main` branch.

**Manual Frontend Deployment:**

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm ci

# Build the application
npm run build

# Deploy to Azure Static Web Apps
az staticwebapp deploy \
  --resource-group <resource-group-name> \
  --name <static-web-app-name> \
  --source ./dist
```

### 3. Database Setup

The database is automatically created when the application starts using Entity Framework Core's `EnsureCreated()` method.

**Manual Database Setup:**

```bash
# Connect to Azure SQL Database
sqlcmd -S <server-name>.database.windows.net -d <database-name> -U <username> -P <password>

# Run any necessary database scripts
# The application will create tables automatically
```

### 4. Configuration

#### Environment Variables

Configure the following environment variables in Azure App Service:

- `ASPNETCORE_ENVIRONMENT`: `Production`
- `ConnectionStrings__DefaultConnection`: Database connection string
- `ApplicationInsights__InstrumentationKey`: Application Insights key

#### Connection String

The connection string is automatically configured through Terraform, but you can manually set it:

```
Server=tcp:<server-name>.database.windows.net,1433;Initial Catalog=<database-name>;Persist Security Info=False;User ID=<username>;Password=<password>;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
```

### 5. Verification

After deployment, verify the system is working:

1. **API Health Check**
   - Navigate to `https://<app-service-name>.azurewebsites.net/swagger`
   - Verify Swagger UI loads correctly

2. **Frontend Health Check**
   - Navigate to `https://<static-web-app-name>.azurestaticapps.net`
   - Verify the application loads correctly

3. **Database Connection**
   - Check Application Insights for any database connection errors
   - Verify tables are created in the database

## CI/CD Pipeline

The project includes comprehensive CI/CD automation:

### Workflows

1. **Infrastructure Deployment** (`infra.yml`)
   - Triggers on changes to `infrastructure/` directory
   - Validates and deploys Terraform configuration
   - Updates repository secrets

2. **Application Deployment** (`deploy_app.yml`)
   - Triggers on changes to application code
   - Builds and tests both frontend and backend
   - Deploys to Azure services
   - Runs integration tests

3. **Quality Assurance** (`sonar.yml`)
   - Runs SonarQube analysis
   - Generates code coverage reports
   - Validates quality gates

4. **Documentation** (`publish_doc.yml`)
   - Generates API documentation
   - Publishes to GitHub Pages

5. **Class Diagrams** (`class_diagram.yml`)
   - Generates UML diagrams
   - Updates documentation

6. **Release Management** (`release.yml`)
   - Creates releases with version tags
   - Generates deployment packages
   - Updates changelog

### Secrets Configuration

Configure the following secrets in GitHub:

- `AZURE_CLIENT_ID`: Azure service principal client ID
- `AZURE_CLIENT_SECRET`: Azure service principal secret
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `AZURE_WEBAPP_PUBLISH_PROFILE_API`: App Service publish profile
- `AZURE_STATIC_WEB_APPS_API_TOKEN`: Static Web Apps deployment token
- `SONAR_TOKEN`: SonarCloud authentication token
- `PERSONAL_ACCESS_TOKEN`: GitHub personal access token (optional)

## Troubleshooting

### Common Issues

1. **Infrastructure Deployment Fails**
   - Check Azure credentials and permissions
   - Verify Terraform configuration
   - Check for naming conflicts

2. **Application Deployment Fails**
   - Verify build artifacts
   - Check application settings
   - Review deployment logs

3. **Database Connection Issues**
   - Verify connection string
   - Check firewall rules
   - Ensure SQL Server is accessible

4. **Frontend Build Fails**
   - Check Node.js version
   - Verify dependencies
   - Review build configuration

### Monitoring

Monitor the deployment using:

- **Application Insights**: Application performance and errors
- **Log Analytics**: Centralized logging
- **Azure Monitor**: Infrastructure metrics
- **GitHub Actions**: Deployment status

### Rollback

If deployment fails:

1. **Infrastructure Rollback**
   ```bash
   cd infrastructure
   terraform destroy
   terraform apply
   ```

2. **Application Rollback**
   - Use Azure App Service deployment slots
   - Revert to previous deployment
   - Update connection strings if needed

## Security Considerations

- Use managed identities where possible
- Store secrets in Azure Key Vault
- Enable HTTPS for all endpoints
- Configure firewall rules appropriately
- Regular security updates and patches

## Cost Optimization

- Use Free tier for development
- Scale down resources during non-business hours
- Monitor usage and costs
- Use reserved instances for production

## Support

For deployment issues:

1. Check the GitHub Actions logs
2. Review Azure portal for errors
3. Check Application Insights
4. Create an issue in the repository

---

**Note**: This deployment guide assumes you have the necessary Azure permissions and resources configured. Contact your Azure administrator if you encounter permission issues.
