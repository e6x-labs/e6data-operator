aws_region                  = "us-east-1"
workspace_name              = "harshith"

eks_cluster_name            = "e6-engine"
desired_instances_in_eks_nodegroup = 3
eks_nodegroup_instance_types     = ["t3.large"]
max_instances_in_eks_nodegroup  = 5
min_instances_in_eks_nodegroup  = 3
eks_disk_size                = 100

bucket_names                  = ["*"]

kubernetes_namespace = "e6data"

e6data_cross_oidc_role_arn = "arn:aws:iam::298655976287:role/stg-e6-apps-aws-infra-oidc-role" 

e6data_tags = {
  Team = "PLT"
  Operation = "Product"
  Environment = "Dev"
  App = "e6data"
  User = "dev@e6x.io"
  permanent = "true"
}