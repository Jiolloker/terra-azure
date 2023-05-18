# Define the MySQL server
resource "azurerm_mysql_server" "db-server" {
  name                = "${random_pet.prefix.id}-db-mysql-server"
  resource_group_name = azurerm_resource_group.desafio.name
  location            = azurerm_resource_group.desafio.location
  version             = "5.7" # Choose the desired MySQL version


  sku_name = "B_Gen5_1"



  storage_mb                        = 32768 # Specify the desired storage size
  auto_grow_enabled                 = false
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"



  administrator_login          = "adminuser" # Replace with your desired admin username
  administrator_login_password = var.db-pwd  # Replace with your desired admin password

  tags = {
    terraform   = "true"
    environment = "dev"
    db = "mysql"
  }
}


# Random Prefix
resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}

resource "azurerm_private_endpoint" "private-endpoint" {
  name                = "${random_pet.prefix.id}-endpoint"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.desafio.name
  subnet_id           = azurerm_subnet.desafio-subnet.id

  private_service_connection {
    name                           = "${random_pet.prefix.id}-privateserviceconnection"
    private_connection_resource_id = azurerm_mysql_server.db-server.id
    subresource_names              = [ "mysqlServer" ]
    is_manual_connection           = false
  }
}
