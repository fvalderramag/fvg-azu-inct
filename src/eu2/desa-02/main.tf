# ==========================================
# Paso 1: Grupo de Recursos (Resource Group)
# ==========================================
resource "azurerm_resource_group" "rg_jira" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Project     = "Jira-Integrations"
  }
}

# ==========================================
# Paso 2: Azure Key Vault (Modelo Azure RBAC)
# ==========================================
resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.rg_jira.location
  resource_group_name        = azurerm_resource_group.rg_jira.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Habilita el modelo de permisos Azure RBAC  
  enable_rbac_authorization = true

  # Acceso público habilitado (redes abiertas)
  public_network_access_enabled = true

  tags = azurerm_resource_group.rg_jira.tags
}

# Permiso temporal para que el Service Principal de Terraform pueda insertar los secretos
resource "azurerm_role_assignment" "tf_runner_kv_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ==========================================
# Paso 3: Secretos dentro del Key Vault
# ==========================================
resource "azurerm_key_vault_secret" "jira_token" {
  name         = "jira-token"
  value        = var.jira_token_value
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.tf_runner_kv_officer]
}

resource "azurerm_key_vault_secret" "confluence_token" {
  name         = "confluence-token"
  value        = var.confluence_token_value
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.tf_runner_kv_officer]
}

# =========================================================
# Paso 4: Microsoft Entra ID - App Registration & Principal
# =========================================================
resource "azuread_application" "scriptrunner_app" {
  display_name     = "app-scriptrunner-kv-client"
  sign_in_audience = "AzureADMyOrg" # Single Tenant
}

resource "azuread_service_principal" "scriptrunner_sp" {
  client_id = azuread_application.scriptrunner_app.client_id
}

# ==========================================
# Paso 5: Generar el Client Secret
# ==========================================
resource "azuread_application_password" "scriptrunner_secret" {
  application_id = azuread_application.scriptrunner_app.id
  display_name   = "jira-scriptrunner-secret"
  end_date       = timeadd(timestamp(), "4320h") # Vigencia aprox. de 180 días (180 * 24h)

  lifecycle {
    ignore_changes = [end_date]
  }
}

# =========================================================================
# Paso 6: Asignar Rol RBAC (Key Vault Secrets User) a la aplicación
# =========================================================================
resource "azurerm_role_assignment" "scriptrunner_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.scriptrunner_sp.object_id
}
