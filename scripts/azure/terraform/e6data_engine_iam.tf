# role assignment to provide permission to service principal to read the data in the containers
resource "azurerm_role_assignment" "e6data_identity_read_role" {
  for_each             = var.list_of_containers != ["*"] ? toset(var.list_of_containers) : [""]
  scope                = each.value != "" ? "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.e6data_rg.name}/providers/Microsoft.Storage/storageAccounts/${azurerm_storage_account.e6data_storage_account.name}/blobServices/default/containers/${each.value}" : "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.e6data_rg.name}/providers/Microsoft.Storage/storageAccounts/${azurerm_storage_account.e6data_storage_account.name}"
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_user_assigned_identity.e6data_identity.principal_id
}
# managed identity role assignment to provide read and write access to the e6data managed storage account
resource "azurerm_role_assignment" "e6data_identity_write_role" {
  scope                = azurerm_storage_account.e6data_storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.e6data_identity.principal_id
}
