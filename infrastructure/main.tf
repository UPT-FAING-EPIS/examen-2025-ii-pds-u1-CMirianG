terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateattendance"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

# App Service Plan (Free Tier for students)
resource "azurerm_service_plan" "main" {
  name                = "${var.project_name}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "F1"  # Free tier

  tags = var.common_tags
}

# App Service for API
resource "azurerm_linux_web_app" "api" {
  name                = "${var.project_name}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on = false  # Required for free tier
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLite"
    value = "Data Source=attendance.db"
  }

  tags = var.common_tags
}

# Static Web App for Frontend
resource "azurerm_static_site" "frontend" {
  name                = "${var.project_name}-frontend"
  resource_group_name = azurerm_resource_group.main.name
  location            = "West Europe"  # Static Web Apps limited regions
  sku_tier            = "Free"
  sku_size            = "Free"

  tags = var.common_tags
}

# Application Insights for monitoring
resource "azurerm_application_insights" "main" {
  name                = "${var.project_name}-insights"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  application_type    = "web"

  tags = var.common_tags
}

# Log Analytics Workspace (required for App Insights)
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-logs"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.common_tags
}
