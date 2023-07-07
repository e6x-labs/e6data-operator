terraform {
    required_providers {
        tls = {
            source = "hashicorp/tls"
            version = "3.4.0"
        }
    }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      app  = "e6data"
    }
  }
}