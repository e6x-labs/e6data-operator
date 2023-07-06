# resource "aws_iam_role" "s3_access_role" {
#   name = "cross-account-s3-access-role"
  
#   assume_role_policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Principal": {
#           "AWS": "arn:aws:iam::<e6data_account_id>:root"
#         },
#         "Action": "sts:AssumeRole"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "s3_read_policy" {
#   name        = "s3-read-policy"
#   description = "Allows read access to S3 bucket"

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": [
#           "s3:GetObject",
#           "s3:ListBucket"
#         ],
#         "Resource": [
#           "arn:aws:s3:::${aws_s3_bucket.workspace_bucket.name}",
#           "arn:aws:s3:::${aws_s3_bucket.workspace_bucket.name}/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "s3_read_policy_attachment" {
#   role       = aws_iam_role.s3_access_role.name
#   policy_arn = aws_iam_policy.s3_read_policy.arn
# }
