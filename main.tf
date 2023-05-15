# Define the resource group
resource "azurerm_resource_group" "desafio" {
  name     = "desafio-resource-group"
  location = "eastus"
}

# Define the virtual network
resource "azurerm_virtual_network" "desafio-vnet" {
  name                = "desafio-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desafio.name
}

# Define the subnet
resource "azurerm_subnet" "desafio-subnet" {
  name                 = "desafio-subnet"
  resource_group_name  = azurerm_resource_group.desafio.name
  virtual_network_name = azurerm_virtual_network.desafio-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Define the network interface template
resource "azurerm_network_interface" "desafio_template" {
  count               = var.web_server_count
  name                = "desafio-nic-template-${count.index}"
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desafio.name

  ip_configuration {
    name                          = "desafio-ipconfig-${count.index}"
    subnet_id                     = azurerm_subnet.desafio-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the public IP address
resource "azurerm_public_ip" "desafio-publicip" {
  name                = "desafio-publicip"
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desafio.name
  allocation_method   = "Dynamic"
}

# Define the load balancer
resource "azurerm_lb" "desafio-lb" {
  name                = "desafio-lb"
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desafio.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.desafio-publicip.id
  }
}

# Define the backend pool
resource "azurerm_lb_backend_address_pool" "desafio" {
  name            = "desafio-backendpool"
  loadbalancer_id = azurerm_lb.desafio-lb.id
}

# Define the probe
resource "azurerm_lb_probe" "desafio" {
  name            = "desafio-probe"
  loadbalancer_id = azurerm_lb.desafio-lb.id
  resource_group_name = azurerm_resource_group.desafio.name
  protocol        = "Tcp"
  port            = 22
}

# Define the load balancer rule
resource "azurerm_lb_rule" "desafio-1" {
  name                           = "desafio-lbrule"
  loadbalancer_id                = azurerm_lb.desafio-lb.id
  resource_group_name            = azurerm_resource_group.desafio.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.desafio.id]
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.desafio-lb.frontend_ip_configuration[0].name
  frontend_port                  = 80
  protocol                       = "Tcp"
  probe_id                       = azurerm_lb_probe.desafio.id
}

# Define the load balancer rule for ssh
resource "azurerm_lb_rule" "desafio-2" {
  name                           = "ssh-inbound-rule"
  loadbalancer_id                = azurerm_lb.desafio-lb.id
  resource_group_name            = azurerm_resource_group.desafio.name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.desafio.id]
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.desafio-lb.frontend_ip_configuration[0].name
  frontend_port                  = 22
  protocol                       = "Tcp"
  probe_id                       = azurerm_lb_probe.desafio.id
}



# Associate the network interface with the load balancer backend pool
resource "azurerm_network_interface_backend_address_pool_association" "web_nic_lb_associate" {
  count                   = var.web_server_count
  network_interface_id    = azurerm_network_interface.desafio_template.*.id[count.index]
  ip_configuration_name   = azurerm_network_interface.desafio_template.*.ip_configuration.0.name[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.desafio.id
}

# Create the web servers and associate them with the load balancer backend pool
resource "azurerm_linux_virtual_machine" "desafio_web_server" {
  count                 = var.web_server_count
  name                  = "desafio-web-server-${count.index}"
  location              = azurerm_resource_group.desafio.location
  resource_group_name   = azurerm_resource_group.desafio.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = ["${element(azurerm_network_interface.desafio_template.*.id, count.index)}"]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.admin_ssh_key
  }

  os_disk {
    name                 = "disk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    terraform   = "true"
    environment = "dev"
    approle     = "web-server"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "desafio-nsg" {
  name                = "desafio-nsg"
  location            = azurerm_resource_group.desafio.location
  resource_group_name = azurerm_resource_group.desafio.name


  #Add rule for Inbound Access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


#Connect NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "desafio-nsg-assoc" {
  subnet_id                 = azurerm_subnet.desafio-subnet.id
  network_security_group_id = azurerm_network_security_group.desafio-nsg.id
}