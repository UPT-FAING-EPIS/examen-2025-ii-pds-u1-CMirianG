output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.main.name
}

output "api_url" {
  description = "URL of the API App Service"
  value       = "https://${azurerm_linux_web_app.api.default_hostname}"
}

output "frontend_url" {
  description = "URL of the Static Web App"
  value       = "https://${azurerm_static_site.frontend.default_host_name}"
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "static_web_app_api_key" {
  description = "Static Web App API key for deployment"
  value       = azurerm_static_site.frontend.api_key
  sensitive   = true
}
