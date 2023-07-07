resource "aws_iam_role" "e6data_cross_account_role" {
  name = "cross-account-s3-access-role"
  
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.e6data_account_id}:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "e6data_cross_account_s3_policy" {
  name        = "s3-read-policy"
  description = "Allows read and write access to e6data workspace bucket"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListObjects",
            "s3:DeleteObject",
            "s3:GetObjectVersion",
            "s3:DeleteObjectVersion",
            "s3:DeleteObject"
        ],
        "Resource": [
          "arn:aws:s3:::${aws_s3_bucket.workspace_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.workspace_bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "eks_cluster_access_policy" {
  name        = "eks-cluster-access-policy"
  description = "Allows connecting to an EKS cluster"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "eks:DescribeCluster"
        ],
        "Resource": "arn:aws:eks:${var.aws_region}:${data.aws_caller_identity.current.account_id}:cluster/${var.eks_cluster_name}"      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "e6data_cross_account_s3_policy_attachment" {
  role       = aws_iam_role.e6data_cross_account_role.name
  policy_arn = aws_iam_policy.e6data_cross_account_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "eks_cluster_access_policy_attachment" {
  role       = aws_iam_role.e6data_cross_account_role.name
  policy_arn = aws_iam_policy.eks_cluster_access_policy.arn
}
