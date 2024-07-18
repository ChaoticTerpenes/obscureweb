#!/bin/bash

#The admin interface for OpenVPN

echo "Content-type: text/html"
echo ""
echo "<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Obscure OpenVPN Server</title>
</head>
<body>"

echo "<h1>Obscure OpenVPN Server</h1>"

eval `echo "${QUERY_STRING}"|tr '&' ';'`

IP=$(wget -4qO- "http://whatismyip.akamai.com/")

newclient () {
	# Generates the custom client.ovpn
	cp /etc/openvpn/client.conf.template /etc/openvpn/clients/$1.ovpn
	echo "<ca>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/ca.crt >> /etc/openvpn/clients/$1.ovpn
	echo "</ca>" >> /etc/openvpn/clients/$1.ovpn
	echo "<cert>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/issued/$1.crt >> /etc/openvpn/clients/$1.ovpn
	echo "</cert>" >> /etc/openvpn/clients/$1.ovpn
	echo "<key>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/easy-rsa/pki/private/$1.key >> /etc/openvpn/clients/$1.ovpn
	echo "</key>" >> /etc/openvpn/clients/$1.ovpn
	echo "<tls-auth>" >> /etc/openvpn/clients/$1.ovpn
	cat /etc/openvpn/server/ta.key >> /etc/openvpn/clients/$1.ovpn
	echo "</tls-auth>" >> /etc/openvpn/clients/$1.ovpn
}

cd /etc/openvpn/easy-rsa/

case $option in
	"add") #Add a client
		./easyrsa --batch build-client-full $client nopass > /dev/null 2>&1
		# Generates the custom client.ovpn
		newclient "$client"  > /dev/null 2>&1
		echo "<h3>Certificate for client <span style='color:red'>$client</span> added.</h3>"
	;;
	"revoke") #Revoke a client
		echo "<span style='display:none'>"
		./easyrsa --batch revoke $client > /dev/null 2>&1
		./easyrsa gen-crl > /dev/null 2>&1
		echo "</span>"
		rm -rf pki/reqs/$client.req
		rm -rf pki/private/$client.key
		rm -rf pki/issued/$client.crt
		rm -rf /etc/openvpn/crl.pem
		rm -rf /etc/openvpn/clients/$client.ovpn
		cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
		# CRL is read with each client connection, when OpenVPN is dropped to nobody
		echo "<h3>Certificate for client <span style='color:red'>$client</span> revoked.</h3>"
	;;
esac

NUMBEROFCLIENTS=$(ls -l /etc/openvpn/clients/ | grep ".ovpn" | cut -d " " -f 9 | cut -d "." -f 1 | wc -l)
if [[ "$NUMBEROFCLIENTS" = '0' ]]; then
        echo "<h3>You have no existing clients.<h3>"
else
        echo "<h3>You have $NUMBEROFCLIENTS existing clients.<h3>"
        while read c; do
        if [[ $(echo $c | wc -l) = '1' ]]; then
                clientName=$(echo $c)
                echo "<p><a href='index.sh?option=revoke&client=$clientName'>Revoke</a> <a target='_blank' href='download.sh?client=$clientName'>Download</a> $clientName</p>"
        fi
        done < <(ls -l /etc/openvpn/clients/ | grep ".ovpn" | cut -d " " -f 9 | cut -d "." -f 1)
fi
echo "<form action='index.sh' method='get'><input type='hidden' name='option' value='add'>New Client: <input type='text' name='client'><input type='submit' value='Add'></form>"
echo "</body></html>"
exit 0
