# Create EKS node group for workspace
resource "aws_eks_node_group" "workspace" {
  cluster_name    = data.aws_eks_cluster.current.name
  node_group_name = local.e6data_workspace_name
  node_role_arn   = aws_iam_role.e6data_bucket_role.arn
  subnet_ids      = var.subnet_ids
  capacity_type = "SPOT"
  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = var.max_instances_in_nodegroup
  }
  instance_types = [var.nodegroup_instance_type]
}

# Create S3 bucket for workspace
resource "aws_s3_bucket" "workspace_bucket" {
  bucket = local.e6data_workspace_name
}

resource "aws_s3_bucket_acl" "workspace_bucket_acl" {
  bucket = aws_s3_bucket.workspace_bucket.id
  acl    = "private"
}
