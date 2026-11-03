terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_prueba" {
  name     = "rg-fvg-desa-02"
  location = "eastus2"

  tags = {
    Ambiente   = "desa"
    CreadoPor  = "Terraform-Cloud"
  }
}
