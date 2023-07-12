variable "subscription_id" {
  type        = string
  description = "The subscription ID of the Azure subscription in which the e6data resources will be deployed."
  default     = "2b69ff5f-bcfa-4f86-a43c-c06ca182c584"
}

variable "workspace_name" {
  type        = string
  description = "Name of the e6data workspace to be created.."
  default     = "har"
}

variable "e6data_app_secret_expiration_time" {
  type        = string
  description = "A relative duration for which the password is valid until, for example 240h (10 days) or 2400h30m."
  default     = "3600h"
}

variable "aks_cluster_name" {
  type        = string
  description = "The name of your Azure Kubernetes Service (AKS) cluster in which to deploy the e6data workspace."
  default     = "testpoc"
}

variable "aks_resource_group_name" {
  type        = string
  description = "The name of the resource group where the AKS cluster is deployed."
  default     = "test123"
}

variable "vm_size" {
  type        = string
  description = "The VM size for the AKS node pool.(for example Standard_DS2_v2)"
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
  description = "The namespace in the AKS cluster to deploy e6data workspace."
  default     = "default"
}

variable "data_resource_group_name" {
  type        = string
  description = "The name of the resource group containing data to be queried."
  default     = "data-rg"
}

variable "data_storage_account_name" {
  type        = string
  description = "The name of the storage account containing data to be queried."
  default     = "data-storage-account"
}

variable "list_of_containers" {
  type        = list(string)
  description = "List of names of the containers inside the data storage account, that the 6data engine queries and require read access to."
  default     = ["*"]
}
