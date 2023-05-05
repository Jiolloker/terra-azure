terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
                version = "3.53.0"
        }
    }
}

provider "azurerm" {
    subscription_id = var.subscription_id
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
    features {}
}

resource "azurerm_resource_group" "rg" {
    name     = "eduit-rg"
    location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.2.0.0/20"]

  subnet {
    name           = "default"
    address_prefix = "10.2.1.0/24"  
  }

  subnet {
    name           = "frontend"
    address_prefix = "10.2.2.0/24"
  }

    subnet {
        name = "backend"
        address_prefix = "10.2.3.0/24"
    }

  tags = {
    env = "prod"
  }
}