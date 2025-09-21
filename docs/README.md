# Attendance System Documentation

This repository contains a comprehensive attendance management system built with modern technologies and best practices.

## 🏗️ Architecture Overview

The Attendance System follows a microservices architecture with the following components:

- **Frontend**: React 18 with TypeScript and Tailwind CSS
- **Backend**: .NET 8 Web API with Entity Framework Core
- **Database**: Azure SQL Database
- **Infrastructure**: Azure App Service and Static Web Apps
- **CI/CD**: GitHub Actions with comprehensive automation

## 📋 Features

### Core Functionality
- Student registration and management
- Course and session management
- Real-time attendance tracking
- Comprehensive reporting system
- Responsive web interface

### Technical Features
- RESTful API with Swagger documentation
- Repository pattern implementation
- Dependency injection
- Entity Framework Core with Code First
- React with TypeScript
- Tailwind CSS for styling
- Comprehensive test coverage

## 🚀 Quick Start

### Prerequisites
- .NET 8.0 SDK
- Node.js 18+
- Azure CLI
- Git

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/examen-2025-ii-pds-u1-CMirianG.git
   cd examen-2025-ii-pds-u1-CMirianG
   ```

2. **Backend Setup**
   ```bash
   cd backend/AttendanceSystem.API
   dotnet restore
   dotnet build
   dotnet run
   ```

3. **Frontend Setup**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

4. **Access the application**
   - Frontend: http://localhost:5173
   - API: http://localhost:5000
   - Swagger: http://localhost:5000/swagger

## 🏛️ Infrastructure as Code

The infrastructure is defined using Terraform and includes:

- Azure Resource Group
- App Service Plan (Free tier)
- Linux Web App for API
- Static Web App for frontend
- Azure SQL Database
- Application Insights
- Log Analytics Workspace

### Deploy Infrastructure
```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

## 🔄 CI/CD Pipeline

The project includes comprehensive GitHub Actions workflows:

1. **Infrastructure Deployment** (`infra.yml`)
   - Terraform validation and deployment
   - Infrastructure diagram generation

2. **Application Deployment** (`deploy_app.yml`)
   - Build and test both frontend and backend
   - Deploy to Azure services
   - Integration testing

3. **Quality Assurance** (`sonar.yml`)
   - SonarQube analysis
   - Code coverage reporting
   - Quality gate validation

4. **Documentation** (`publish_doc.yml`)
   - Generate API documentation
   - Publish to GitHub Pages

5. **Class Diagrams** (`class_diagram.yml`)
   - Generate UML diagrams
   - Update documentation

6. **Release Management** (`release.yml`)
   - Automated release creation
   - Package generation
   - Changelog generation

## 📊 Quality Metrics

The project maintains high quality standards:

- **Code Coverage**: Target 90%
- **Bugs**: 0 tolerance
- **Vulnerabilities**: 0 tolerance
- **Security Hotspots**: 0 tolerance
- **Code Duplication**: <10 lines

## 🛠️ Development Guidelines

### Backend Development
- Follow C# coding standards
- Use dependency injection
- Implement repository pattern
- Write comprehensive tests
- Document API endpoints

### Frontend Development
- Use TypeScript for type safety
- Follow React best practices
- Implement responsive design
- Use Tailwind CSS for styling
- Write component tests

### Infrastructure
- Use Terraform for IaC
- Follow Azure naming conventions
- Implement proper security
- Monitor with Application Insights

## 📚 API Documentation

The API documentation is automatically generated and available at:
- Swagger UI: `/swagger`
- OpenAPI Specification: `/swagger/v1/swagger.json`

### Key Endpoints
- `GET /api/attendance` - Get all attendance records
- `POST /api/attendance` - Create new attendance record
- `GET /api/courses` - Get all courses
- `POST /api/courses` - Create new course
- `GET /api/sessions` - Get all sessions
- `POST /api/sessions` - Create new session
- `GET /api/reports/attendance/{courseId}` - Get attendance report

## 🔧 Configuration

### Environment Variables
- `ASPNETCORE_ENVIRONMENT`: Production/Development
- `ConnectionStrings__DefaultConnection`: Database connection string
- `ApplicationInsights__InstrumentationKey`: Monitoring key

### Azure Configuration
- App Service settings are configured through Terraform
- Connection strings are managed securely
- Application Insights is enabled for monitoring

## 📈 Monitoring and Logging

- **Application Insights**: Performance monitoring and telemetry
- **Log Analytics**: Centralized logging
- **Health Checks**: API endpoint monitoring
- **Metrics**: Custom application metrics

## 🚀 Deployment

### Automatic Deployment
The system automatically deploys when changes are pushed to the main branch:

1. Infrastructure changes trigger Terraform deployment
2. Application changes trigger build and deployment
3. Quality checks run before deployment
4. Documentation is updated automatically

### Manual Deployment
For manual deployment:

1. **Infrastructure**
   ```bash
   cd infrastructure
   terraform apply
   ```

2. **Backend**
   ```bash
   cd backend/AttendanceSystem.API
   dotnet publish -c Release -o ./publish
   # Deploy to Azure App Service
   ```

3. **Frontend**
   ```bash
   cd frontend
   npm run build
   # Deploy to Azure Static Web Apps
   ```

## 🧪 Testing

### Backend Testing
```bash
cd backend
dotnet test
```

### Frontend Testing
```bash
cd frontend
npm test
```

### Integration Testing
Integration tests run automatically in the CI/CD pipeline.

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and quality checks
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🤝 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the API documentation

## 🎯 Roadmap

- [ ] Mobile application
- [ ] Advanced reporting features
- [ ] Integration with external systems
- [ ] Multi-tenant support
- [ ] Advanced analytics dashboard

---

**Built with ❤️ using modern technologies and best practices**
