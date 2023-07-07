data "aws_iam_policy_document" "iam_eks_node_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "e6data_iam_eks_node_role" {
  name = "e6data-eks-node-role"
  managed_policy_arns = var.iam_eks_node_policy_arn
  assume_role_policy = data.aws_iam_policy_document.iam_eks_node_assume_policy.json
}
