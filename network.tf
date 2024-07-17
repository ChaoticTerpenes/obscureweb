# VPN Hub Network Configuration
resource "random_id" "randomId-nw" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  }

  byte_length = 2
}

# VPN Hub Virtual Network
resource "azurerm_virtual_network" "vpn_hub_vnet" {
  name                = "${var.prefix-vpn-hub}-${random_id.randomId-nw.hex}-vnet"
  location            = "${azurerm_resource_group.vpn_hub_vnet-rg.location}"
  resource_group_name = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  address_space       = ["10.0.0.0/8"]
  dns_servers         = ["${var.VPN_DNS1}", "${var.VPN_DNS2}"]

  tags = {
    environment = "VPN Hub"
  }
}

# VPN Hub Gateway subnet 10.1.0.0 - 10.1.0.15
resource "azurerm_subnet" "vpn_hub_gateway_subnet" {
  name                 = "${var.prefix-vpn-hub}-${random_id.randomId-nw.hex}-gateway-subnet"
  resource_group_name  = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vpn_hub_vnet.name}"
  address_prefixes     = ["10.1.0.0/28"]
}

# Subnet for vpnserver instance 10.1.0.15 - 10.1.0.31
resource "azurerm_subnet" "vpn_hub_subnet" {
  name                 = "${var.prefix-vpn-hub}-${random_id.randomId-nw.hex}-vpn-subnet"
  resource_group_name  = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vpn_hub_vnet.name}"
  address_prefixes       = ["10.1.0.16/28"]
}

# Subnet for Management instances 10.1.0.48 - 10.1.0.63
resource "azurerm_subnet" "vpn_hub_atk_subnet" {
  name                 = "${var.prefix-vpn-hub}-${random_id.randomId-nw.hex}-atk-subnet"
  resource_group_name  = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vpn_hub_vnet.name}"
  address_prefixes       = ["10.1.0.48/28"]
}

# Subnet for client instances 10.1.0.128 - 10.1.0.255
resource "azurerm_subnet" "vpn_hub_client_subnet" {
  name                 = "${var.prefix-vpn-hub}-${random_id.randomId-nw.hex}-client-subnet"
  resource_group_name  = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vpn_hub_vnet.name}"
  address_prefixes       = ["10.1.0.128/25"]
}
