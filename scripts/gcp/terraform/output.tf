output "gke_nodegroup_name" {
  value = local.e6data_workspace_name
}

output "gke_nodegroup_max_instances" {
  value = var.max_instances_in_nodegroup
}

output "workspace_gcs_bucket_name" {
  value = local.e6data_workspace_name
}

output "e6data_workspace_gsa_email" {
  value = google_service_account.workspace_sa.email
}

output "e6data_workspace_name" {
  value = var.workspace_name
}

output "kubernetes_namespace" {
  value = var.kubernetes_namespace
}