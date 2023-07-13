# service principal role assignment to provide read and write access to the e6data managed storage account
resource "azurerm_role_assignment" "e6data_app_blob_role" {
  scope                = azurerm_storage_account.e6data_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.e6data_service_principal.object_id
}

# custom role definition to the service principal to get the aks credentials
resource "azurerm_role_definition" "e6data_aks_custom_role" {
  name        = "e6data aks custom role"
  description = "Custom role to list the aks cluster credential"
  scope       = data.azurerm_subscription.primary.id
  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/listClusterUserCredential/action"
    ]
    not_actions = []
  }
}

# custom role assigment to the service principal to get the aks credentials
resource "azurerm_role_assignment" "e6data_aks_custom_role_assignment" {
  scope                = data.azurerm_kubernetes_cluster.customer_aks.id
  role_definition_id   = azurerm_role_definition.e6data_aks_custom_role.role_definition_resource_id
  principal_id         = azuread_service_principal.e6data_service_principal.object_id
}
