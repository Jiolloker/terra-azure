output "web_server_1_public_ip" {
  value = azurerm_network_interface.web_nic_1.id
}

output "mysql_server_public_ip" {
  value = azurerm_mysql_server.example.id
}