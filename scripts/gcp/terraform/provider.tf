terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.72.0"
    }
  }
}

provider "google" {
    project = var.project_id
    #access_token = "{{ gcp_access_token }}"
}