########################
# Cloudflare Variables #
########################
cloudflare-api-key  = "" # My Profile - API Tokens - Global API Key
cloudflare-api-user = "" # This is the email address associated with the CF Account
cloudflare-zone-id  = "" # My Profile - API Tokens - Create Token 
###################
# Azure Variables #
###################
azure-subscription-id = "" # This data is displayed in your subscription overivew
azure-client-id       = "" # This data id displayed in App Registrations overview for the respective app
azure-client-secret   = "" # This data id displayed in App Registrations - Manage - Certificates & secrets for the respective app
azure-tenant-id       = "" # This data id displayed in App Registrations overview for the respective app
student_managed_disk  = "" # Go to your managed disk properties to get the info for this field
environment           = "obscureweb"
location              = "eastus"
###############
# Credentials #
###############
vpnserver_username     = "obscurevpn"
atk_username           = "atk"
windows_username       = "student"
vpnserver_password     = ""
atk_password           = ""
windows_password       = ""
ansible-password       = ""
##############
# ObscureVPN #
##############
#Domain is spelt different because the word is taken
DOUGHMAIN = {
    "VPNSERVER" = "" # Example: vpnserver
    "LOCATION"  = "" # Example: awesomedomain that you own with cloudflare
    "ZONE"      = "com" # Example: .com || .net || .awesome || etc.
}
# az vm image list --publisher Canonical --output table
vpnserver_hostname     = "vpn"
obscure-vpn-publisher  = "Canonical"
obscure-vpn-offer      = "0001-com-ubuntu-server-jammy"
obscure-vpn-sku        = "22_04-lts-gen2"
obscure-vpn-version    = "latest"
vpnserver_vmsize       = "Standard_B2ms"
vpnserver_nic          = "vpn0"
ansible_inventory_template   = "./scripts/linux/vpn/obscureweb.template"
lighttpd_template      = "./scripts/linux/vpn/lighttpd.conf.template"
networking_template    = "./scripts/linux/vpn/networking.sh.template"
vars_template          = "./scripts/linux/vpn/vars.template"
dh_pem                 = "./scripts/linux/vpn/dh4096.pem"
server_conf            = "./scripts/linux/vpn/server.conf.template"
client_template        = "./scripts/linux/vpn/client.conf.template"
ssh_public_key_file    = "./scripts/linux/ssh_keys/ovpn.pub"
ssh_private_key_file   = "./scripts/linux/ssh_keys/ovpn"
VPN_COMPRESSION        = "compress lz4"
VPN_DNS1               = "1.1.1.1"
VPN_DNS2               = "8.8.8.8"
VPN_PRIVATE_IP         = "10.1.0.20"
VPN_PORT               = "1194"
VPN_PROTOCOL           = "udp"
VPN_HUB                = {"SUBNET"="10.1.0.0","CIDR"="24","NETMASK"="255.255.255.0"}
VPN_CLIENT             = {"SUBNET"="10.8.0.0","CIDR"="24","NETMASK"="255.255.255.0"}
EASYRSA_DN             = "org"
EASYRSA_REQ_COUNTRY	   = "US"
EASYRSA_REQ_PROVINCE   = "Virgina"
EASYRSA_REQ_CITY	   = "Virgina"
EASYRSA_REQ_ORG	       = "example" 
EASYRSA_REQ_EMAIL	   = "no-reply@example.com"
EASYRSA_REQ_OU		   = "example"
EASYRSA_KEY_SIZE	   = 4096
EASYRSA_CA_EXPIRE	   = 3650
EASYRSA_CERT_EXPIRE	   = 1080
EASYRSA_CRL_DAYS	   = 3650
EASYRSA_DIGEST		   = "sha512"
##############
#    atk     #
##############
atk_hostname       = "obscureatk"
atk_ip_address     = "10.1.0.52"
atk-vpn-publisher  = "Canonical"
atk-vpn-offer      = "0001-com-ubuntu-server-jammy"
atk-vpn-sku        = "22_04-lts-gen2"
atk-vpn-version    = "latest"
ubuntu_os_version  = "22.04"
atk_vmsize         = "Standard_B2ms"
##############
#  Windows   #
##############
#az vm image list --location eastus --publisher MicrosoftWindowsDesktop --offer Windows-11 --sku win11-22h2-ent --all
windows_hostname     = "student"
windows_private_ip   = "10.1.0.132"
windows-publisher    = "MicrosoftWindowsDesktop"
windows-offer        = "windows-11"
windows-sku          = "win11-23h2-ent"
windows-version      = "22631.3737.240607"
windows_vmsize       = "Standard_D2s_v3"
windows_nic          = "student0"
student = "student"
student1 = "student1"
student2 = "student2"
student3 = "student3"
student4 = "student4"
student5 = "student5"
student6 = "student6"
student7 = "student7"
student8 = "student8"
student9 = "student9"
student10 = "student10"
student11 = "student11"
student12 = "student12"
student13 = "student13"
student14 = "student14"
student15 = "student15"
student16 = "student16"
student17 = "student17"
student18 = "student18"
student19 = "student19"
student20 = "student20"
studentIP1 = "10.1.0.201"
studentIP2 = "10.1.0.202"
studentIP3 = "10.1.0.203"
studentIP4 = "10.1.0.204"
studentIP5 = "10.1.0.205"
studentIP6 = "10.1.0.206"
studentIP7 = "10.1.0.207"
studentIP8 = "10.1.0.208"
studentIP9 = "10.1.0.209"
studentIP10 = "10.1.0.210"
studentIP11 = "10.1.0.211"
studentIP12 = "10.1.0.212"
studentIP13 = "10.1.0.213"
studentIP14 = "10.1.0.214"
studentIP15 = "10.1.0.215"
studentIP16 = "10.1.0.216"
studentIP17 = "10.1.0.217"
studentIP18 = "10.1.0.218"
studentIP19 = "10.1.0.219"
studentIP20 = "10.1.0.220"
##############
# Networking #
##############
allowed_inbound_ip_addresses = ""
vpn_gateway_subnet           = "GatewaySubnet"
vpn_client_subnet            = "client_VPNSubnet"
###################
# Security Groups #
###################
vpn_hub-sg                  = "vpnserver-SecurityGroup"
client-sg                   = "student-SecurityGroup"
client_PublicIP             = "public_client-SecurityGroup"
prefix-vpn-hub              = "obscure-hub"