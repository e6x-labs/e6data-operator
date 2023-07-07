locals {
  e6data_workspace_name = "e6data-workspace-${var.workspace_name}"
  workspace_write_role_name = "e6data_${var.workspace_name}_write"
  workspace_read_role_name = "e6data_${var.workspace_name}_read"
  kubernetes_cluster_location = var.aws_region
}

data "aws_caller_identity" "current" {
}

data "aws_eks_cluster" "current" {
  name     = var.eks_cluster_name
}