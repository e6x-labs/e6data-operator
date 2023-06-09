# Create EKS node group for workspace
resource "aws_eks_node_group" "workspace_node_group" {
  cluster_name    = data.aws_eks_cluster.current.name
  node_group_name = local.e6data_workspace_name
  node_role_arn   = aws_iam_role.eks_nodegroup_iam_role.arn
  subnet_ids      = data.aws_eks_cluster.current.vpc_config[0].subnet_ids
  disk_size       = var.eks_disk_size
  capacity_type   = "SPOT"
  force_update_version = true
  instance_types = var.eks_nodegroup_instance_types
  scaling_config {
    desired_size = var.desired_instances_in_eks_nodegroup
    min_size     = var.min_instances_in_eks_nodegroup
    max_size     = var.max_instances_in_eks_nodegroup
  }

  update_config {
    max_unavailable = 2
  }

  tags = {
    "Name" = local.e6data_workspace_name
    "k8s.io/cluster-autoscaler/enabled" =  "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
  }

    depends_on = [ aws_iam_role.eks_nodegroup_iam_role ]
}

module "eks_nodegroup_tags" {

  for_each = var.e6data_tags

  source = "./modules/eks_tags"
  autoscaling_group_name = aws_eks_node_group.workspace_node_group.resources[0].autoscaling_groups[0].name
  tag_key = each.key
  tag_value = each.value

  depends_on = [ aws_eks_node_group.workspace_node_group ]
}

data "aws_iam_policy_document" "eks_nodegroup_iam_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_nodegroup_iam_role" {
  name = local.e6data_workspace_name
  managed_policy_arns = var.eks_nodegroup_iam_policy_arn
  assume_role_policy = data.aws_iam_policy_document.eks_nodegroup_iam_assume_policy.json
}