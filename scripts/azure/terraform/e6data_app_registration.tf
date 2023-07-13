# Create an Azure AD application
resource "azuread_application" "e6data_app" {
  display_name     = "${var.workspace_name}-app"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMultipleOrgs"
}

# Create an Azure AD application password
resource "azuread_application_password" "e6data_secret" {
  application_object_id             = azuread_application.e6data_app.id
  end_date_relative                 = var.e6data_app_secret_expiration_time
}

# Create an Azure AD service principal
resource "azuread_service_principal" "e6data_service_principal" {
  application_id = azuread_application.e6data_app.application_id
  owners       = [data.azuread_client_config.current.object_id]
}