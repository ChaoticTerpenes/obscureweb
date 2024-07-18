# Template for shell script ./scripts/server.conf.template
data "template_file" "vpn_server_configuration_file" {
  template = "${file("${var.server_conf}")}"

  vars = {
    VPN_PORT           = "${var.VPN_PORT}"
    VPN_PROTOCOL       = "${var.VPN_PROTOCOL}"
    VPN_CLIENT_CIDR    = "${var.VPN_CLIENT["CIDR"]}"
    VPN_CLIENT_SUBNET  = "${var.VPN_CLIENT["SUBNET"]}"
    VPN_CLIENT_NETMASK = "${var.VPN_CLIENT["NETMASK"]}"
    VPN_HUB_SUBNET     = "${var.VPN_HUB["SUBNET"]}"
    VPN_HUB_NETMASK    = "${var.VPN_HUB["NETMASK"]}"
    VPN_DNS1           = "${var.VPN_DNS1}"
    VPN_DNS2           = "${var.VPN_DNS2}"
    LOCATION           = "${var.location}"
    VPN_HOST           = "${var.vpnserver_hostname}"
    VPN_PRIVATE_IP     = "${var.VPN_PRIVATE_IP}"
    VPN_DOMAIN         = "${var.DOUGHMAIN["VPNSERVER"]}.${var.DOUGHMAIN["LOCATION"]}.${var.DOUGHMAIN["ZONE"]}"
    VPN_COMPRESSION    = "${var.VPN_COMPRESSION}"
  }
}

# Template for shell script ./scripts/client.conf.template
data "template_file" "vpn_client_template_file" {
  template = "${file("${var.client_template}")}"

  vars = {
    VPN_PORT           = "${var.VPN_PORT}"
    VPN_PROTOCOL       = "${var.VPN_PROTOCOL}"
    VPN_CLIENT_CIDR    = "${var.VPN_CLIENT["CIDR"]}"
    VPN_CLIENT_SUBNET  = "${var.VPN_CLIENT["SUBNET"]}"
    VPN_CLIENT_NETMASK = "${var.VPN_CLIENT["NETMASK"]}"
    VPN_HUB_SUBNET     = "${var.VPN_HUB["SUBNET"]}"
    VPN_HUB_NETMASK    = "${var.VPN_HUB["NETMASK"]}"
    VPN_DNS1           = "${var.VPN_DNS1}"
    VPN_DNS2           = "${var.VPN_DNS2}"
    LOCATION           = "${var.location}"
    VPN_HOST           = "${var.vpnserver_hostname}"
    VPN_PRIVATE_IP     = "${var.VPN_PRIVATE_IP}"
    VPN_DOMAIN         = "${var.DOUGHMAIN["VPNSERVER"]}.${var.DOUGHMAIN["LOCATION"]}.${var.DOUGHMAIN["ZONE"]}"
    VPN_COMPRESSION    = "${var.VPN_COMPRESSION}"
  }
}

# Template for shell script ./scripts/linux/vpn/lighttpd.conf.template
data "template_file" "lighttpd_template_file" {
  template = "${file("${var.lighttpd_template}")}"

  vars = {
    HOST     = "${var.DOUGHMAIN["VPNSERVER"]}"
    LOCATION = "${var.DOUGHMAIN["LOCATION"]}"
    ADMIN    = "${var.vpnserver_username}"
    PASS     = "${var.vpnserver_password}"
  }
}
# Template for Easy-Rsa VARS ./scripts/linux/vpn/vars.template
data "template_file" "vars_template_file" {
  template = "${file("${var.vars_template}")}"

  vars = {
    EASYRSA_DN            = "${var.EASYRSA_DN}"
    EASYRSA_REQ_COUNTRY   = "${var.EASYRSA_REQ_COUNTRY}"
    EASYRSA_REQ_PROVINCE  = "${var.EASYRSA_REQ_PROVINCE}"
    EASYRSA_REQ_CITY      = "${var.EASYRSA_REQ_CITY}"
    EASYRSA_REQ_ORG       = "${var.EASYRSA_REQ_ORG}"
    EASYRSA_REQ_EMAIL     = "${var.EASYRSA_REQ_EMAIL}"
    EASYRSA_REQ_OU        = "${var.EASYRSA_REQ_OU}"
    EASYRSA_KEY_SIZE      = "${var.EASYRSA_KEY_SIZE}"
    EASYRSA_CA_EXPIRE     = "${var.EASYRSA_CA_EXPIRE}"
    EASYRSA_CERT_EXPIRE   = "${var.EASYRSA_CERT_EXPIRE}"
    EASYRSA_CRL_DAYS      = "${var.EASYRSA_CRL_DAYS}"
    EASYRSA_DIGEST        = "${var.EASYRSA_DIGEST}"
  }
}

# Template for shell script ./scripts/linux/vpn/networking.sh.template
data "template_file" "networking_template_file" {
  template = "${file("${var.networking_template}")}"

  vars = {
    VPN_CLIENT_CIDR    = "${var.VPN_CLIENT["CIDR"]}"
    VPN_CLIENT_SUBNET  = "${var.VPN_CLIENT["SUBNET"]}"
    VPN_CLIENT_NETMASK = "${var.VPN_CLIENT["NETMASK"]}"
  }
}

# Create openvpn virtual machine
resource "azurerm_virtual_machine" "openvpn" {
  name                  = "${var.vpnserver_hostname}-${random_id.randomId.hex}"
  location              = "${azurerm_resource_group.vpn_hub_vnet-rg.location}"
  resource_group_name   = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.vpnserver_nic.id}"]
  vm_size               = "${var.vpnserver_vmsize}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_os_disk {
    name              = "${var.vpnserver_hostname}-${random_id.randomId.hex}_os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = var.obscure-vpn-publisher
    offer     = var.obscure-vpn-offer
    sku       = var.obscure-vpn-sku
    version   = var.obscure-vpn-version
  }

  os_profile {
    computer_name  = "${var.vpnserver_hostname}"
    admin_username = "${var.vpnserver_username}"
    admin_password = "${var.vpnserver_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.vpnserver_username}/.ssh/authorized_keys"
      key_data = "${file(var.ssh_public_key_file)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "sudo cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.$$",
      "sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "${var.vpnserver_username}"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Install Openvpn and other required binarys
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo NEEDRESTART_MODE=a apt -y update",
      "sudo NEEDRESTART_MODE=a apt -y autoremove",
      "sudo NEEDRESTART_MODE=a apt -y install curl wget",
      "sudo add-apt-repository -y universe",
      "sudo add-apt-repository -y ppa:certbot/certbot",
      #"sudo curl -s https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -",
      #"echo 'deb http://build.openvpn.net/debian/openvpn/stable jammy main' > /etc/apt/sources.list.d/openvpn-aptrepo.list",
      "sudo NEEDRESTART_MODE=a apt -y update",
      "sudo NEEDRESTART_MODE=a apt -y install gcc software-properties-common",
      "sudo NEEDRESTART_MODE=a apt -y install make",
      "sudo NEEDRESTART_MODE=a apt -y install lighttpd",
      "sudo NEEDRESTART_MODE=a apt -y install openvpn",
      "sudo NEEDRESTART_MODE=a apt -y install ca-certificates",
      "sudo NEEDRESTART_MODE=a apt -y install openssl",
      "sudo NEEDRESTART_MODE=a apt -y install certbot",
      "sudo NEEDRESTART_MODE=a apt -y install net-tools",
      #"sudo NEEDRESTART_MODE=a apt -y install python3-pip",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Provision dh.pem - Create the DH parameters file using the predefined ffdhe2048 group
  provisioner "file" {
    source      = "${var.dh_pem}"
    destination = "/etc/openvpn/server/dh4096.pem"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Render the vars file for easy-rsa CA creation
  provisioner "file" {
    source      = "./scripts/linux/vpn/vars"
    destination = "/tmp/vars"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Install Latest verions of EasyRSA and setup CA Authority
  provisioner "remote-exec" {
    inline = [
      "echo \"Sleeping for 30 seconds...\" && sleep 30",
      "sudo mv /etc/openvpn/easy-rsa/ /etc/openvpn/easy-rsa.$$.old > /dev/null 2>&1", #//If old easy-rsa exists then it will move to backup dir. 
      "sudo curl -s https://api.github.com/repos/OpenVPN/easy-rsa/releases/latest | grep 'browser_download_url.*tgz' | cut -d : -f 2,3 | tr -d '$\"' | awk '!/sig/' | wget -O /tmp/EasyRSA.tgz -qi -",
      "sudo tar -zxvf /tmp/EasyRSA.tgz --transform 's/EasyRSA-3.2.0/easy-rsa/' --one-top-level=/etc/openvpn/",
      "sudo chown -R root:root /etc/openvpn/easy-rsa/",
      "sudo rm -rf /tmp/EasyRSA.tgz",
      "sudo mv /tmp/vars /etc/openvpn/easy-rsa/",
      "cd /etc/openvpn/easy-rsa/",
      "sudo ./easyrsa init-pki",
      "sudo touch /etc/openvpn/easy-rsa/pki/.rnd",
      "sudo ./easyrsa --batch --req-cn=${var.vpnserver_hostname}-RootCA build-ca nopass",
      "sudo ./easyrsa --batch build-server-full ${var.vpnserver_hostname} nopass",
      "sudo ./easyrsa gen-crl",
      "sudo cp pki/ca.crt pki/private/ca.key pki/issued/${var.vpnserver_hostname}.crt pki/private/${var.vpnserver_hostname}.key /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/server/",
      "sudo chown nobody:nogroup /etc/openvpn/server/crl.pem",
      "sudo openvpn --genkey --secret /etc/openvpn/server/ta.key",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Script for network adjustments such as IP forwarding.
  provisioner "file" {
    content     = "${data.template_file.networking_template_file.rendered}"
    destination = "/tmp/networking.sh"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  ## Enable net.ipv4.ip_forward for the system and ## Firewall UFW Settings 
  provisioner "remote-exec" {
    inline = [
      "sleep 15",
      "sudo chmod 775 /tmp/networking.sh",
      "sudo /tmp/networking.sh",
      #"sudo rm -rf /tmp/networking.sh",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  ## Adjust permissions for openvpn to be available via HTTPS 
  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "sudo rm /var/www/html/*",
      "sudo mkdir /etc/openvpn/clients/",
      "sudo chown -R www-data:www-data /etc/openvpn/easy-rsa",
      "sudo chown -R www-data:www-data /etc/openvpn/clients/",
      "sudo chmod -R 755 /etc/openvpn/",
      "sudo chmod -R 777 /etc/openvpn/server/crl.pem",
      "sudo chmod g+s /etc/openvpn/clients/",
      "sudo chmod g+s /etc/openvpn/easy-rsa/",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "10m"
    }
  }

  # Setup script for lighttpd client website
  provisioner "file" {
    source      = "./scripts/linux/vpn/index.sh"
    destination = "/var/www/html/index.sh"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Setup script for lighttpd client website
  provisioner "file" {
    source      = "./scripts/linux/vpn/download.sh"
    destination = "/var/www/html/download.sh"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  ## LetsEncrypt SSL cert for Lighttpd
  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "sudo systemctl stop lighttpd.service",
      "sudo certbot certonly --standalone -n -d ${var.DOUGHMAIN["VPNSERVER"]}.${var.DOUGHMAIN["LOCATION"]}.${var.DOUGHMAIN["ZONE"]} --email noreply@chaoticcyber.com --agree-tos --redirect --hsts",
      "sudo cat /etc/letsencrypt/live/${var.DOUGHMAIN["VPNSERVER"]}.${var.DOUGHMAIN["LOCATION"]}.${var.DOUGHMAIN["ZONE"]}/privkey.pem /etc/letsencrypt/live/${var.DOUGHMAIN["VPNSERVER"]}.${var.DOUGHMAIN["LOCATION"]}.${var.DOUGHMAIN["ZONE"]}/cert.pem > /etc/letsencrypt/live/${var.DOUGHMAIN["VPNSERVER"]}.${var.DOUGHMAIN["LOCATION"]}.${var.DOUGHMAIN["ZONE"]}/combined.pem",
      "sudo chown -R www-data:www-data /var/www/html/",
      "sudo mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.$$",
      "sudo echo '${var.vpnserver_username}:${var.vpnserver_password}' >> /etc/lighttpd/.lighttpdpassword",
      "sudo chmod g+x /etc/letsencrypt",
      "sudo chmod g+x /etc/letsencrypt/live",
    ]
    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Render the server.conf.template template file -> server.conf
  provisioner "file" {
    content     = "${data.template_file.vpn_server_configuration_file.rendered}"
    destination = "/etc/openvpn/server/server.conf"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Render the lient.conf.template template file
  provisioner "file" {
    content     = "${data.template_file.vpn_client_template_file.rendered}"
    destination = "/etc/openvpn/client.conf.template"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Render the lighttpd.conf template file
  provisioner "file" {
    content     = "${data.template_file.lighttpd_template_file.rendered}"
    destination = "/etc/lighttpd/lighttpd.conf"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  ## Enable openvpn and lighttpd server and restart service 
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start openvpn-server@server.service",
      "sudo systemctl restart lighttpd.service",
      "sudo systemctl enable openvpn-server@server.service",
      "sudo systemctl enable lighttpd.service",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  ## Setup ansible user 
  provisioner "remote-exec" {
    inline = [
      "sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/ansible --gecos \"\" ansible",
      "sudo usermod -aG sudo ansible",
      "echo 'ansible-playbook /etc/ansible/hosts/atk/juicy_shop_deploy.yml' > /home/ansible/deploy-juicy.sh",
      "echo 'ansible-playbook /etc/ansible/hosts/atk/webgoat_deploy.yml' > /home/ansible/deploy-goat.sh",
      "echo 'ansible-playbook /etc/ansible/hosts/atk/web_dvwa_deploy.yml' > /home/ansible/deploy-dvwa.sh",
      "sudo chown -R ansible:ansible /home/ansible/",
      "cd /home/ansible",
      "sudo chmod +x deploy-juicy.sh deploy-goat.sh deploy-dvwa.sh",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Allow ansible ssh access with key from host
  provisioner "remote-exec" {
    inline = [
      "sleep 15",
      "sudo mkdir /home/ansible/.ssh",
      "sudo cp /root/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys.$$",
      "sudo cp /root/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys",
      "sudo chown -R ansible:ansible /home/ansible/.ssh"
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "${var.vpnserver_username}"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Install Ansible
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo NEEDRESTART_MODE=a apt-add-repository -y ppa:ansible/ansible > /dev/null 2>&1",
      "sudo NEEDRESTART_MODE=a apt update > /dev/null 2>&1",
      "sudo NEEDRESTART_MODE=a apt install -y -qq ansible > /dev/null 2>&1",
      "sudo rm -rf /etc/ansible/hosts > /dev/null 2>&1",
      "sudo NEEDRESTART_MODE=a apt install -y python-pip > /dev/null 2>&1",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "${var.vpnserver_username}"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  # Copy ansible files
  provisioner "file" {
    source      = "./ansible/"
    destination = "/etc/ansible"

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "root"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }

  ## Reboot vpnserver (optional)
  provisioner "remote-exec" {
    inline = [
      "echo 'Scheduling instance reboot in one minute ...'",
      "sudo shutdown -r +1 > /dev/null 2>&1",
    ]

    connection {
      host        = "${azurerm_public_ip.PublicIP.ip_address}"
      type        = "ssh"
      user        = "${var.vpnserver_username}"
      private_key = "${file("${var.ssh_private_key_file}")}"
      timeout     = "5m"
    }
  }
}

# VPNSERVER PublicIP
resource "azurerm_public_ip" "PublicIP" {
  name                = "${var.vpnserver_hostname}-${random_id.randomId.hex}-public"
  resource_group_name = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  location            = "${azurerm_resource_group.vpn_hub_vnet-rg.location}"
  allocation_method   = "Static"
  domain_name_label   = "${var.DOUGHMAIN["VPNSERVER"]}" #//adds dns using hostname.centralus.cloudapp.azure.com
}

# VPNSERVER Network Interface
resource "azurerm_network_interface" "vpnserver_nic" {
  name                      = "${var.vpnserver_nic}-${random_id.randomId.hex}"
  location                  = "${azurerm_resource_group.vpn_hub_vnet-rg.location}"
  resource_group_name       = "${azurerm_resource_group.vpn_hub_vnet-rg.name}"
  enable_ip_forwarding      = true


  ip_configuration {
    name                          = "${var.vpnserver_hostname}-${random_id.randomId.hex}"
    subnet_id                     = "${azurerm_subnet.vpn_hub_subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address           = "${var.VPN_PRIVATE_IP}"
    public_ip_address_id = "${azurerm_public_ip.PublicIP.id}"
  }
}

resource "azurerm_network_interface_security_group_association" "vpnserver-nic" {
  network_interface_id      = azurerm_network_interface.vpnserver_nic.id
  network_security_group_id = azurerm_network_security_group.vpn-sg.id
}

resource "cloudflare_record" "vpn" {
  zone_id          = var.cloudflare-zone-id
  name             = "${var.DOUGHMAIN["VPNSERVER"]}"
  value            = azurerm_public_ip.PublicIP.ip_address
  type             = "A"
  proxied          = false
  allow_overwrite  = true
}