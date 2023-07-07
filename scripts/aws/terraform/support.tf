locals {
  e6data_workspace_name = "e6data-workspace-${var.workspace_name}"
  bucket_names_with_full_path = [for bucket_name in var.bucket_names : "arn:aws:s3:::${bucket_name}/*"]
  bucket_names_with_arn = [for bucket_name in var.bucket_names : "arn:aws:s3:::${bucket_name}"]
}

data "aws_caller_identity" "current" {
}

data "aws_eks_cluster" "current" {
  name     = var.eks_cluster_name
}

