output "secret" {
  sensitive = true
  value = azuread_application_password.e6data_secret.value
}

output "application_id" {
  sensitive = true
  value = azuread_application.e6data_app.application_id
}

output "tenant_id" {
  sensitive = true
  value = data.azurerm_client_config.current.tenant_id
}