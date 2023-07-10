# Create a node pool in the AKS cluster
# The name of the node pool must be between 1 to 12 characters in length
resource "azurerm_kubernetes_cluster_node_pool" "e6data_node_pool" {
  name                    = "${var.workspace_name}nodepool"
  kubernetes_cluster_id   = data.azurerm_kubernetes_cluster.customer_aks.id
  vm_size                 = var.vm_size
  enable_auto_scaling     = true
  min_count               = var.min_number_of_nodes
  max_count               = var.max_number_of_nodes
  tags                    = local.default_tags
}