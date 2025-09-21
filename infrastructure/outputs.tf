# Output values for the infrastructure

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "api_url" {
  description = "The URL of the API web app"
  value       = "https://${azurerm_linux_web_app.api.default_hostname}"
}

output "frontend_url" {
  description = "The URL of the frontend static web app"
  value       = "https://${azurerm_static_site.frontend.default_host_name}"
}

output "static_web_app_api_key" {
  description = "The API key for the static web app"
  value       = azurerm_static_site.frontend.api_key
  sensitive   = true
}

output "sql_server_name" {
  description = "The name of the SQL server"
  value       = azurerm_mssql_server.main.name
}

output "sql_database_name" {
  description = "The name of the SQL database"
  value       = azurerm_mssql_database.main.name
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL server"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "application_insights_name" {
  description = "The name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "app_service_plan_name" {
  description = "The name of the App Service plan"
  value       = azurerm_service_plan.main.name
}

output "app_service_plan_sku" {
  description = "The SKU of the App Service plan"
  value       = azurerm_service_plan.main.sku_name
}

output "connection_string" {
  description = "The connection string for the database"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Persist Security Info=False;User ID=${azurerm_mssql_server.main.administrator_login};Password=${azurerm_mssql_server.main.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

output "swagger_url" {
  description = "The URL to access the API Swagger documentation"
  value       = "https://${azurerm_linux_web_app.api.default_hostname}/swagger"
}