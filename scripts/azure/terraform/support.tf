#default tags for all the resources
locals {
  default_tags = {
    app          = "e6data"
  }
}
# Retrieve information about an existing Azure Kubernetes Service (AKS) cluster
data "azurerm_kubernetes_cluster" "customer_aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group_name
}

#retrieves information about the primary Azure subscription.
data "azurerm_subscription" "primary" {
  subscription_id = var.subscription_id
}

#retrieves the current Azure Active Directory (Azure AD) client configuration.
data "azuread_client_config" "current" {}

#retrieves the current Azure client configuration.
data "azurerm_client_config"  "current" {}