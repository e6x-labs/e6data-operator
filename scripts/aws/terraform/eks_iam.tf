resource "aws_iam_openid_connect_provider" "e6data_oidc_provider" {
  url             = data.aws_eks_cluster.current.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
}  

resource "aws_iam_role" "e6data_bucket_role" {
  name = "workspace-bucket-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.e6data_oidc_provider.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${aws_iam_openid_connect_provider.e6data_oidc_provider.url}:sub": "system:serviceaccount:kube-system:aws-node"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "workspace_bucket_read_policy" {
  name        = "s3-read-policy"
  description = "Provides read access to specific S3 buckets"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "workspace_bucket_write_policy" {
  name        = "s3-write-policy"
  description = "Allows write access to S3 bucket"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.workspace_bucket.id}/*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "workspace_bucket_read_policy_attachment" {
  role       = aws_iam_role.e6data_bucket_role.name
  policy_arn = aws_iam_policy.workspace_bucket_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "workspace_bucket_write_policy_attachment" {
  role       = aws_iam_role.e6data_bucket_role.name
  policy_arn = aws_iam_policy.workspace_bucket_write_policy.arn
}