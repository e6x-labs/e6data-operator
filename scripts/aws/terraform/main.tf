# Create EKS node group for workspace
resource "aws_eks_node_group" "workspace" {
  cluster_name    = data.aws_eks_cluster.current.name
  node_group_name = local.e6data_workspace_name
  node_role_arn   = aws_iam_role.e6data_iam_eks_node_role.arn
  subnet_ids      = var.subnet_ids
  disk_size       = var.eks_disk_size
  capacity_type   = "SPOT"
  force_update_version = true
  instance_types = var.nodegroup_instance_types
  scaling_config {
    desired_size = var.desired_instances_in_nodegroup
    min_size     = var.min_instances_in_nodegroup
    max_size     = var.max_instances_in_nodegroup
  }

  update_config {
    max_unavailable = 2
  }

  tags = {
    "Name" = "e6data-asg"
    "k8s.io/cluster-autoscaler/enabled" =  "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
  }
}

# Create S3 bucket for workspace
resource "aws_s3_bucket" "workspace_bucket" {
  bucket = local.e6data_workspace_name
}

resource "aws_s3_bucket_acl" "workspace_bucket_acl" {
  bucket = aws_s3_bucket.workspace_bucket.id
  acl    = "private"
}