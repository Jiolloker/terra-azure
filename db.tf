# Define the resource group
resource "azurerm_resource_group" "db-rg" {
  name     = "db-resource-group"
  location = "eastus"
}

# Define the MySQL server
resource "azurerm_mysql_server" "db-server" {
  name                = "db-mysql-server"
  resource_group_name = azurerm_resource_group.db-rg.name
  location            = azurerm_resource_group.db-rg.location
  version             = "5.7" # Choose the desired MySQL version

  sku {
    name     = "B_Gen5_1"
    tier     = "basic"
    capacity = 1
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 32768 # Specify the desired storage size
    backup_retention_days = 0     # Specify the desired backup retention period
    geo_redundant_backup  = "Disabled"
  }

  infrastructure_encryption {
    enabled = false # Disable infrastructure encryption
  }

  delete_data_disks_on_deletion = true       # Delete data disks when the server is deleted
  storage_auto_grow             = "Disabled" # Disable automatic storage growth
  backup_enforcement            = "Disabled" # Disable backup enforcement
  diagnostics_settings {
    log_analytics_destination {
      enabled = false # Disable boot diagnostics
    }
  }

  administrator_login          = "adminuser" # Replace with your desired admin username
  administrator_login_password = var.db-pwd  # Replace with your desired admin password
}


