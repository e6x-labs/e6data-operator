# Create user-assigned identity, which can be assigned to Azure resources for authentication and access control purposes.
resource "azurerm_user_assigned_identity" "e6data_identity" {
  location            = azurerm_resource_group.e6data_rg.location
  name                = "${var.workspace_name}-identity"
  resource_group_name = azurerm_resource_group.e6data_rg.name
  tags                  = local.default_tags

}

# This resource block creates a federated identity credential, which can be used for authentication and authorization from the AKS.
resource "azurerm_federated_identity_credential" "e6data_federated_credential" {
  name                = "${var.workspace_name}-federated-credential"
  audience            = ["api://AzureADTokenExchange"]
  resource_group_name = azurerm_resource_group.e6data_rg.name
  issuer              = data.azurerm_kubernetes_cluster.customer_aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.e6data_identity.id
  subject             = "system:serviceaccount:${var.aks_namespace}:${var.serviceaccount_name}"
}
