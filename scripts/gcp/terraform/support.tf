locals {
  workspace_namespace = "e6data-workspace-${var.workspace_name}"
  workspace_write_role_name = "e6data_${var.workspace_name}_write"
  workspace_read_role_name = "e6data_${var.workspace_name}_read"
  workspace_sa_email = "${local.workspace_namespace}@${var.project_id}.iam.gserviceaccount.com"
  platform_sa_email = "dev-e6-helm-op-whyezopu@e6data-analytics.iam.gserviceaccount.com"
}

data "google_project" "current" {
}

data "google_container_cluster" "current" {
  name     = var.cluster_name
  location = var.cluster_zone
}
