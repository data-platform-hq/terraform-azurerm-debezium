terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.1"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2.1"
    }
  }
}
