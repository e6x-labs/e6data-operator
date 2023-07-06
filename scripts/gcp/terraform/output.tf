output "GKE_NODEGROUP_NAME" {
  value = local.workspace_namespace
}

output "GKE_NODEGROUP_MAX_INSTANCES" {
  value = var.max_instances_in_nodegroup
}

output "WORKSPACE_GCS_BUCKET_NAME" {
  value = local.workspace_namespace
}

output "E6DATA_WORKSPACE_GSA_EMAIL" {
  value = local.workspace_sa_email
}

output "E6DATA_WORKSPACE_NAME" {
  value = var.workspace_name
}

output "KUBERNETES_NAMESPACE" {
  value = var.kubernetes_namespace
}
