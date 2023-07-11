locals {
  default_tags = {
    app          = "e6data"
  }
  limited_containers = "/subscriptions/${var.subscription_id}/resourceGroups/${var.data_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.data_storage_account_name}/blobServices/default/containers/${join(",", var.list_of_containers)}"
  all_containers = "/subscriptions/${var.subscription_id}/resourceGroups/${var.data_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.data_storage_account_name}"
}

# Retrieve information about the resource group of the aks
data "azurerm_resource_group" "aks_resource_group" {
  name = var.aks_resource_group_name
}

# Retrieve information about the existing Azure Kubernetes Service (AKS) cluster
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