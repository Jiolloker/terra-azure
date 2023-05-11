terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.53.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "rg-desafio" {
  name     = "eduit-rg-desafio"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project}-vnet"
  location            = azurerm_resource_group.rg-desafio.location
  resource_group_name = azurerm_resource_group.rg-desafio.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    env = "dev"
  }
}


resource "azurerm_subnet" "web" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.rg-desafio.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "mysql" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.rg-desafio.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}



resource "azurerm_network_security_group" "rg-desafio" {
  name                = "desafio-nsg"
  location            = azurerm_resource_group.rg-desafio.location
  resource_group_name = azurerm_resource_group.rg-desafio.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_subnet.web.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.rg-desafio.name
  network_security_group_name = azurerm_network_security_group.rg-desafio.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "ssh"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_subnet.web.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.rg-desafio.name
  network_security_group_name = azurerm_network_security_group.rg-desafio.name
}

resource "azurerm_network_security_rule" "mysql" {
  name                        = "mysql"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = azurerm_subnet.web.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.mysql.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.rg-desafio.name
  network_security_group_name = azurerm_network_security_group.rg-desafio.name
}


resource "azurerm_network_security_rule" "mysql_outbound" {
  name                        = "mysql_outbound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = azurerm_subnet.mysql.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.web.address_prefixes[0]
  resource_group_name         = azurerm_resource_group.rg-desafio.name
  network_security_group_name = azurerm_network_security_group.rg-desafio.name
}
/*
resource "azurerm_network_interface" "web_nic" {
  name                = "web-nic"
  location            = azurerm_resource_group.rg-desafio.location
  resource_group_name = azurerm_resource_group.rg-desafio.name

  ip_configuration {
    name                          = "web-ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                = "web-vm"
  resource_group_name = azurerm_resource_group.rg-desafio.name
  location            = azurerm_resource_group.rg-desafio.location
  size                = "Standard_B1s"
  admin_username      = var.admin_id
  admin_password        = var.admin_pwd
  network_interface_ids = [azurerm_network_interface.web_nic.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/my-key.pem.pub")
  }

  os_disk {
    name                 = "web-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}*/

resource "azurerm_network_interface" "mysql" {
  name                = "mysql-nic"
  resource_group_name = azurerm_resource_group.rg-desafio.name
  location            = azurerm_resource_group.rg-desafio.location
  ip_configuration {
    name                          = "mysql-ipconfig"
    subnet_id                     = azurerm_subnet.mysql.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_mysql_server" "example" {
  name                         = "mysql-server3pointdotcero"
  resource_group_name          = azurerm_resource_group.rg-desafio.name
  location                     = azurerm_resource_group.rg-desafio.location
  administrator_login          = var.mysql_id
  administrator_login_password = var.mysql_pwd
  version                      = "5.7"

  sku_name   = "B_Gen5_1"
  storage_mb = 32768
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
  tags = {
    environment = "dev"
  }
}






## WEB SERVERS
resource "azurerm_network_interface" "web_nic_1" {
  name                = "web-nic-1"
  location            = azurerm_resource_group.rg-desafio.location
  resource_group_name = azurerm_resource_group.rg-desafio.name

  ip_configuration {
    name                          = "web-ipconfig"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "web_server_1" {
  name                  = "web-server-1"
  location            = azurerm_resource_group.rg-desafio.location
  resource_group_name = azurerm_resource_group.rg-desafio.name
  network_interface_ids = [azurerm_network_interface.web_nic_1.id]

  size                 = "Standard_B1s"
  admin_username       = var.admin_id
  admin_password       = var.admin_pwd
  computer_name        = "web-server-1"
  #admin ssh key in terraform cloud
  admin_ssh_key {
    username   = var.admin_id
    private_key = var.admin_ssh_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "web-server-osdisk-1"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb      = 30
  }

  tags = {
    environment = "dev"
    approle = "web-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2 php libapache2-mod-php php-mysql",
      "sudo systemctl restart apache2"
    ]
  }
}

output "web_server_1_public_ip" {
  value = azurerm_network_interface.web_nic_1.id
}

output "mysql_server_public_ip" {
  value = azurerm_mysql_server.example.id
}