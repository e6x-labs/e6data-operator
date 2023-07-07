terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.72.0"
    }
  }
}

provider "google" {
    project = var.gcp_project_id
    region = var.gcp_region
    #access_token = "{{ gcp_access_token }}"
}