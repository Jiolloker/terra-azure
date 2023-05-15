# Credentials
variable "subscription_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}

# Define the number of web servers to create
variable "web_server_count" {
  type    = number
  default = 3
}

variable "admin_ssh_key" {
  type = string
}