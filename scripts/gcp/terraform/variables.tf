variable "region" {
  description = "GCP region to run e6data workspace"
}

variable "project_id" {
  description = "GCP project ID"
}

variable "workspace_name" {
  description = "Name of e6data workspace to be created"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
}

variable "max_instances_in_nodegroup" {
  description = "Maximum number of instances in nodegroup"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace"
}

variable "cluster_zone" {
  description = "Kubernetes cluster zone (Only required for zonal clusters)"
}
