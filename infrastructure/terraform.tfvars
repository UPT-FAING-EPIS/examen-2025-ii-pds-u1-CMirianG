# Terraform configuration for UPT Attendance System

resource_group_name = "attendance-system-upt-rg"
location           = "East US"
project_name       = "attendance-system-upt"
environment        = "prod"

common_tags = {
  Project     = "AttendanceSystem"
  Environment = "Production"
  ManagedBy   = "Terraform"
  Owner       = "mircuadros@upt.pe"
  University  = "UPT"
  Course      = "PDS-2025-II"
  Student     = "Cristhian Mirian"
}
