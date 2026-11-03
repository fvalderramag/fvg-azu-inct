output "tenant_id" {
  description = "Directory (tenant) ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "client_id" {
  description = "Application (client) ID"
  value       = azuread_application.scriptrunner_app.client_id
}

output "client_secret_value" {
  description = "Client Secret para ScriptRunner"
  value       = azuread_application_password.scriptrunner_secret.value
  sensitive   = true
}

output "vault_uri" {
  description = "URI del Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "secret_names" {
  description = "Nombres de los secretos almacenados"
  value = [
    azurerm_key_vault_secret.jira_token.name,
    azurerm_key_vault_secret.confluence_token.name
  ]
}
