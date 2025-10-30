#!/bin/bash
# durin
apt-get update
apt install iptables -y
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.222.0.0/16
apt-get install isc-dhcp-relay -y
cat <<EOF > /etc/default/isc-dhcp-relay
SERVERS="192.222.4.2"
INTERFACESv4="eth1 eth2 eth3 eth4 eth5"
OPTIONS=""
EOF
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
service isc-dhcp-relay start

#Aldarion
echo nameserver 192.168.122.1 > /etc/resolv.conf
apt-get update
apt-get install isc-dhcp-server
dhcpd --version
echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server

cat <<EOF > /etc/dhcp/dhcpd.conf
# Subnet untuk Client Dinamis Keluarga Manusia
subnet 192.222.1.0 netmask 255.255.255.0 {
    range 192.222.1.6 192.222.1.34;
    range 192.222.1.68 192.222.1.94;
    option routers 192.222.1.1;
    option broadcast-address 192.222.1.255;
    option domain-name-servers 192.222.3.2;  # IP Erendis
    default-lease-time 600;
    max-lease-time 7200;
}

# Subnet untuk Client Dinamis Keluarga Peri
subnet 192.222.2.0 netmask 255.255.255.0 {
    range 192.222.2.35 192.222.2.67;
    range 192.222.2.96 192.222.2.121;
    option routers 192.222.2.1;
    option broadcast-address 192.222.2.255;
    option domain-name-servers 192.222.3.2;  # IP Erendis
    default-lease-time 600;
    max-lease-time 3600;
}

# Subnet untuk Khamul (Fixed Address)
subnet 192.222.3.0 netmask 255.255.255.0 {
    option routers 192.222.3.1;
    option broadcast-address 192.222.3.255;
    option domain-name-servers 192.222.3.2;  # IP Erendis
}

host Khamul {
    hardware ethernet 02:42:e1:2a:47:00;
    fixed-address 192.222.3.95;
}

# Subnet Aldarion (wajib ada karena DHCP server ada di sini)
subnet 192.222.4.0 netmask 255.255.255.0 {
        range 192.222.4.10 192.222.4.100;
        option routers 192.222.4.1;
        option broadcast-address 192.222.4.255;
        option domain-name-servers 192.168.122.1;
        default-lease-time 600;
        max-lease-time 7200;
}

EOF

echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

service isc-dhcp-server restart
service isc-dhcp-server status

# Client
echo nameserver 192.168.122.1 > /etc/resolv.conf