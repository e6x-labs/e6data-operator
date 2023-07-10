terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.62.1"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id   = var.subscription_id
}