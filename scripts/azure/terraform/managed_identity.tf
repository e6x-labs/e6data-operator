# Create user-assigned identity, which can be assigned to Azure resources for authentication and access control purposes.
resource "azurerm_user_assigned_identity" "e6data_identity" {
  location            = data.azurerm_resource_group.aks_resource_group.location
  name                = "${var.workspace_name}-identity"
  resource_group_name = data.azurerm_resource_group.aks_resource_group.name
  tags                  = local.default_tags
}

# This resource block creates a federated identity credential, which can be used for authentication and authorization from the AKS.
resource "azurerm_federated_identity_credential" "e6data_federated_credential" {
  name                = "${var.workspace_name}-federated-credential"
  audience            = ["api://AzureADTokenExchange"]
  resource_group_name = data.azurerm_resource_group.aks_resource_group.name
  issuer              = data.azurerm_kubernetes_cluster.customer_aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.e6data_identity.id
  subject             = "system:serviceaccount:${var.aks_namespace}:${var.serviceaccount_name}"
}
