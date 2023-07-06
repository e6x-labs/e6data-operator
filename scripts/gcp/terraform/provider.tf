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
    credentials = "/Users/srinathprabhu/Downloads/proven-outpost-351604-b13444a502c4.json"
    region = var.gcp_region
    #access_token = "{{ gcp_access_token }}"
}