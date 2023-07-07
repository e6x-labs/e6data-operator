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

resource "aws_iam_policy" "e6data_workspace_bucket_policy" {
  name        = "s3-read-policy"
  description = "Provides read access to specific S3 buckets"

  policy = <<EOF
{
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
          "arn:aws:s3:::${aws_s3_bucket.workspace_bucket.name}",
          "arn:aws:s3:::${aws_s3_bucket.workspace_bucket.name}/*"
        ]
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListObjects",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}/*",
        "arn:aws:s3:::${var.bucket_name}"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "e6data_workspace_bucket_policy_attachment" {
  role       = aws_iam_role.e6data_bucket_role.name
  policy_arn = aws_iam_policy.e6data_workspace_bucket_policy.arn
}