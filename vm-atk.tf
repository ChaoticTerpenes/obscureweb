variable "ubuntu_os_version_allowedvalues" {
  type = map

  default = {
    "22.04.0-LTS" = "22.04.0-LTS"
    "22.10"       = "22.10"
  }
}

variable "config" {
  type = map

  default = {
    "namespace"                     = "atk"
    "vm_size"                       = "Standard_F1"
    "vm_image_publisher"            = "Canonical"
    "vm_image_offer"                = "UbuntuServer"
  }
}

resource "azurerm_network_security_group" "atk-sg" {
  name                = "${var.config["namespace"]}-${random_id.randomId.hex}-nsg"
  resource_group_name = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  location            = "${azurerm_resource_group.vpn_hub_vnet-rg.location}"

  security_rule {
    name                       = "allow_ssh"
    description                = "Allow inbound traffic on default ssh port 22."
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "ubuntu-nic" {
  name                = "${var.config["namespace"]}-${random_id.randomId.hex}-nic"
  resource_group_name = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  location            = "${azurerm_resource_group.vpn_hub_vnet-rg.location}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.vpn_hub_atk_subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.atk_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "ubuntu-nic" {
  network_interface_id      = azurerm_network_interface.ubuntu-nic.id
  network_security_group_id = azurerm_network_security_group.atk-sg.id
}

resource "azurerm_virtual_machine" "atk-ubuntu" {
  name                = "${var.config["namespace"]}-${random_id.randomId.hex}-vm"
  resource_group_name = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  location            = "${azurerm_resource_group.vpn_hub_vnet-rg.location}"
  network_interface_ids = ["${azurerm_network_interface.ubuntu-nic.id}"]
  vm_size               = "${var.atk_vmsize}"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  
  storage_os_disk {
    name              = "${var.vpnserver_hostname}-${random_id.randomId.hex}-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  
  os_profile {
    computer_name  = var.atk_hostname
    admin_username = var.atk_username
    admin_password = var.atk_password
  }

  storage_image_reference {
    publisher = var.atk-vpn-publisher
    offer     = var.atk-vpn-offer
    sku       = var.atk-vpn-sku
    version   = var.atk-vpn-version
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_virtual_machine_extension" "docker_extension" {
  name                = "${var.config["namespace"]}-${random_id.randomId.hex}-vmextension"
  virtual_machine_id  = "${azurerm_virtual_machine.atk-ubuntu.id}"
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "DockerExtension"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = "true"
  settings                   = "{}"
}