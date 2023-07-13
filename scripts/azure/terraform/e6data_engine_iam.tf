# role assignment to provide permission to service principal to read the data in the containers
resource "azurerm_role_assignment" "e6data_engine_read_role" {
  for_each              = contains(var.list_of_containers, "*") ? toset(["wildcard"]) : toset(var.list_of_containers)
  scope                 = contains(var.list_of_containers, "*") ? local.all_containers : "/subscriptions/${var.subscription_id}/resourceGroups/${var.data_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.data_storage_account_name}/blobServices/default/containers/${each.value}"
  role_definition_name  = "Storage Blob Data Reader"
  principal_id          = azurerm_user_assigned_identity.e6data_identity.principal_id
}

# managed identity role assignment to provide read and write access to the e6data managed storage account
resource "azurerm_role_assignment" "e6data_engine_write_role" {
  scope                = azurerm_storage_account.e6data_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.e6data_identity.principal_id
}