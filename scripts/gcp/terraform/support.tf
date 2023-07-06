locals {
  e6data_workspace_name = "e6data-workspace-${var.workspace_name}"
  workspace_write_role_name = "e6data_${var.workspace_name}_write"
  workspace_read_role_name = "e6data_${var.workspace_name}_read"

  kubernetes_cluster_location = var.kubernetes_cluster_zone != "" ? var.kubernetes_cluster_zone : var.gcp_region
}

data "google_project" "current" {
}

data "google_container_cluster" "current" {
  name     = var.cluster_name
  location = local.kubernetes_cluster_location
}
