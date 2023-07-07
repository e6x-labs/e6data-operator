variable "workspace_name" {
  description = "Name of e6data workspace to be created"
  type        = string
}
variable "e6data_account_id" {
  description = "bucket name wher the data is present"
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

variable "iam_eks_node_policy_arn" {
  type        = list(string)
  description = "List of Policies to attach to the EKS node role"
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientFullAccess"
  ]
}

variable "bucket_name" {
  description = "bucket name wher the data is present"
  type        = string
}

variable "subnet_ids" {
  description = "subnets for eks node group"
  type        = list(string)
}

variable "eks_disk_size" {
  description = "disk size for the disks in node group"
  type        = number
}

variable "nodegroup_instance_types" {
  description = "Instance type for nodegroup"
  type        = list(string)
  default     = ["m5.large","c5.large"]
}

variable "max_instances_in_nodegroup" {
  description = "Maximum number of instances in nodegroup"
  type        = number
}

variable "min_instances_in_nodegroup" {
  description = "Minimum number of instances in nodegroup"
  type        = number
}

variable "desired_instances_in_nodegroup" {
  description = "Desired number of instances in nodegroup"
  type        = number
}