# # Create GKE nodepool for workspace
resource "google_container_node_pool" "workspace" {
  name             = local.workspace_namespace
  location         = var.region
  cluster          = data.google_container_cluster.current.name
  initial_node_count = 1
  autoscaling {
    min_node_count = 1
    max_node_count = var.max_instances_in_nodegroup
  }
  node_config {
    machine_type = "c2-standard-30" 
  }
}

# # Create GCS bucket for workspace
resource "google_storage_bucket" "workspace" {
  name     = local.workspace_namespace
  location = var.region
}

# # Create service account for workspace
resource "google_service_account" "workspace" {
  account_id   = local.workspace_namespace
  display_name = local.workspace_namespace
}

# # Create IAM role for workspace write access on GCS bucket
resource "google_project_iam_custom_role" "workspace_write_role" {
  role_id     = local.workspace_write_role_name
  title       = "Workspace Write Access"
  description = "Custom role for e6data workspace write access"

  permissions = [
    "storage.buckets.get",
    "storage.buckets.create",
    "storage.buckets.list",
    "storage.buckets.delete",
    "storage.objects.create",
    "storage.objects.delete",
    "storage.objects.get",
    "storage.objects.list",
  ]
}

# # Create IAM role for workspace read access on GCS buckets
resource "google_project_iam_custom_role" "workspace_read_role" {
  role_id     = local.workspace_read_role_name
  title       = "Workspace Read Access"
  description = "Custom role for e6data workspace read access"

  permissions = [
    "storage.buckets.get",
    "storage.objects.get",
    "storage.objects.list",
  ]
}

# # Create IAM policy binding for workspace service account and GCS bucket write access
resource "google_project_iam_binding" "workspace_write_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.workspace_write_role.name

  members = [
    "serviceAccount:${google_service_account.workspace.email}",
  ]

  condition {
    title       = "Workspace Write Access"
    description = "Write access to e6data workspace GCS bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${local.workspace_namespace}/\")"
  }
}

# Create IAM policy binding for workspace service account and GCS bucket read access
resource "google_project_iam_binding" "workspace_read_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.workspace_read_role.name

  members = [
    "serviceAccount:${google_service_account.workspace.email}",
  ]
}

resource "google_project_iam_binding" "platform_gcs_read_binding" {
  project = var.project_id
  role    = google_project_iam_custom_role.workspace_write_role.name

  members = [
    "serviceAccount:${local.platform_sa_email}",
  ]

  condition {
    title       = "Workspace Read Access"
    description = "Read access to e6data workspace GCS bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${local.workspace_namespace}/\")"
  }
}

# resource "google_project_iam_binding" "workspace_ksa_mapping" {
#   project = var.project_id
#   role    = "roles/iam.workloadIdentityUser"

#   members = [
#     "serviceAccount:${google_service_account.workspace.email}",
#   ]
# }

# Create IAM policy binding for workspace service account and Kubernetes cluster
resource "google_project_iam_binding" "workspace_ksa_mapping" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${google_service_account.workspace.email}",
  ]

  depends_on = [
    google_service_account.workspace,
  ]
}

# Create IAM policy binding for Platform Service and Kubernetes cluster
resource "google_project_iam_binding" "platform_ksa_mapping" {
  project = var.project_id
  role    = "roles/container.clusterViewer"
  members = [
    "serviceAccount:${local.platform_sa_email}",
  ]
}

