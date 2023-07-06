variable "workspace_name" {
  description = "Name of e6data workspace to be created"
  type        = string
}

variable "max_instances_in_nodegroup" {
  description = "Maximum number of instances in nodegroup"
  type        = number
}

variable "nodegroup_instance_type" {
  description = "Instance type for nodegroup"
  type        = string
}

variable "bucket_name" {
  description = "bucket name wher the data is present"
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}


variable "aws_region" {
  description = "AWS region to run e6data workspace"
  type        = string
}

variable "subnet_ids" {
  description = "subnets for eks node group"
  type        = list(string)
}
