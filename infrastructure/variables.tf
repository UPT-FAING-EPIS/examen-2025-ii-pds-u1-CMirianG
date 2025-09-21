variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "attendance-system-upt-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "attendance-system-upt"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "AttendanceSystem"
    Environment = "Production"
    ManagedBy   = "Terraform"
    Owner       = "Student"
  }
}
