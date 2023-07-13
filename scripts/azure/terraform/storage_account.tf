# Create Azure Storage Account
resource azurerm_storage_account "e6data_storage_account" {
  name                     = "e6data${var.workspace_name}"
  resource_group_name      = var.aks_resource_group_name
  location                 = data.azurerm_resource_group.aks_resource_group.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.default_tags
}

# Create Azure container to store the blobs
resource azurerm_storage_container "e6data_blobs" {
  name                  = "e6data-${var.workspace_name}-blobs"
  storage_account_name  = azurerm_storage_account.e6data_storage_account.name
  container_access_type = "private"
}