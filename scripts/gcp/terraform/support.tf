locals {
  e6data_workspace_name = "e6data-workspace-${var.workspace_name}"
  workspace_write_role_name = "e6data_${var.workspace_name}_write"
  workspace_read_role_name = "e6data_${var.workspace_name}_read"

  kubernetes_cluster_location = var.kubernetes_cluster_zone != "" ? var.kubernetes_cluster_zone : var.gcp_region
  limited_buckets = join("||", [for bucket in var.list_of_buckets : "resource.name.startsWith(\"projects/_/buckets/${bucket}\")"])

  helm_values_file =yamlencode({
    cloud = {
      type = "GCP"
      oidc_value = google_service_account.workspace_sa.email
      control_plane_user = var.control_plane_user
    }
  })
  default_labels = {
    "app" = "e6data"
  }    
}

data "google_project" "current" {
}

data "google_container_cluster" "gke_cluster" {
  name     = var.cluster_name
  location = local.kubernetes_cluster_location
}

data "google_client_config" "default" {}

provider "helm" {
  alias          = "gke_e6data"
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate)
  }
}