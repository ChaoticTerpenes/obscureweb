resource "azurerm_resource_group" "vpn_hub_vnet-rg" {
  name     = "${var.prefix-vpn-hub}-${random_string.arbitrary_id.result}-rg"
  location = "${var.location}"
}

resource "random_string" "arbitrary_id" {
  length  = 4
  numeric = false
  special = false
  upper   = false
}

provider "cloudflare" {
  email     = "${var.cloudflare-api-user}"
  api_key = "${var.cloudflare-api-key}"
}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  }

  byte_length = 2
}