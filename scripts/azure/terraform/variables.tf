variable "subscription_id" {
  type        = string
  description = "The subscription ID of the Azure subscription in which the e6data resources will be deployed."
  default     = "2b69ff5f-bcfa-4f86-a43c-c06ca182c584"
}

variable "workspace_name" {
  type        = string
  description = "Name of the e6data workspace."
  default     = "har"
}

variable "location" {
  type        = string
  description = "The Azure region where the e6data resources will be deployed."
  default     = "EAST US"
}

variable "e6data_app_secret_expiration_time" {
  type        = string
  description = "The expiration time of the secret in ISO 8601 format."
  default     = "24h"
}

variable "aks_cluster_name" {
  type        = string
  description = "The name of the Azure Kubernetes Service (AKS) cluster."
  default     = "testpoc"
}

variable "aks_resource_group_name" {
  type        = string
  description = "The name of the resource group where the AKS cluster is deployed."
  default     = "test123"
}

variable "vm_size" {
  type        = string
  description = "The VM size for the AKS node pool."
  default     = "Standard_DS2_v2"
}

variable "min_number_of_nodes" {
  type        = number
  description = "The minimum number of nodes in the AKS node pool."
  default     = 1
}

variable "max_number_of_nodes" {
  type        = number
  description = "The maximum number of nodes in the AKS node pool."
  default     = 2
}

variable "aks_namespace" {
  type        = string
  description = "The namespace of the AKS cluster."
  default     = "default"
}

variable "list_of_containers" {
  type        = list(string)
  description = "List of container names to grant permissions. Use ['*'] to grant permissions to all containers."
  default     = ["test1","test2"]
}
