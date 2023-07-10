# Create an Azure resource group to hold e6data resources.
resource "azurerm_resource_group" "e6data_rg" {
  name     = "${var.workspace_name}-rg"
  location = var.location
  tags     = local.default_tags
}
