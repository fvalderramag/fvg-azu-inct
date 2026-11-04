variable "resource_group_name" {
  type        = string
  default     = "rg-jira-integrations-prod"
  description = "Nombre del Resource Group"
}

variable "location" {
  type        = string
  default     = "eastus2"
  description = "Región de Azure"
}

variable "key_vault_name" {
  type        = string
  default     = "kv-jira-fvg-01"
  description = "Nombre globalmente único del Key Vault"
}

variable "jira_token_value" {
  type        = string
  default     = "dummy-jira-token-cambiar"
  sensitive   = true
  description = "Valor inicial del token de Jira"
}

variable "confluence_token_value" {
  type        = string
  default     = "dummy-confluence-token-cambiar"
  sensitive   = true
  description = "Valor inicial del token de Confluence"
}
