variable "gcp_region" {
  description = "GCP region to run e6data workspace"
  type = string
}

variable "gcp_project_id" {
  description = "GCP project ID to deploy e6data workspace"
  type = string
}

variable "workspace_name" {
  description = "Name of e6data workspace to be created"
  type = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type = string
}

variable "max_instances_in_nodegroup" {
  description = "Maximum number of instances in nodegroup"
  type = number
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace to deploy e6data workspaces"
  type = string
}

variable "kubernetes_cluster_zone" {
  description = "Kubernetes cluster zone (Only required for zonal clusters)"
  type = string
}

variable "platform_sa_email" {
  description = "Platform service account email"
  type = string
}

variable "nodegroup_instance_type" {
  description = "Instance type for nodegroup"
  type = string
}