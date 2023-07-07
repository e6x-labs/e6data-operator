variable "workspace_name" {
  description = "Name of e6data workspace to be created"
  type        = string
}

variable "aws_region" {
  description = "AWS region to run e6data workspace"
  type        = string
}

variable "eks_cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "eks_nodegroup_iam_policy_arn" {
  type        = list(string)
  description = "List of Policies to attach to the EKS node role"
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
  ]
}

variable "eks_disk_size" {
  description = "disk size for the disks in node group"
  type        = number
}

variable "eks_nodegroup_instance_types" {
  description = "Instance type for nodegroup"
  type        = list(string)
  default     = ["m5.large","c5.large"]
}

variable "max_instances_in_eks_nodegroup" {
  description = "Maximum number of instances in nodegroup"
  type        = number
}

variable "min_instances_in_eks_nodegroup" {
  description = "Minimum number of instances in nodegroup"
  type        = number
}

variable "desired_instances_in_eks_nodegroup" {
  description = "Desired number of instances in nodegroup"
  type        = number
}

variable "kubernetes_namespace" {
  description = "value of kubernetes namespace to deploy e6data workspace"
  type        = string
}

variable "e6data_tags" {
  type = map(string)
  description = "e6data specific tags for isaolation and cost management"
}

variable "e6data_cross_oidc_role_arn" {
  type        = string
  description = "ARN of the cross account role to assume"
}

variable "bucket_names" {
  type        = list(string)
  description = "List of bucket names to be queried by e6data engine"
}

variable "helm_chart_version" {
  description = "Version of e6data workspace helm chart to deploy"
  type        = string
}