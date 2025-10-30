#!/bin/bash
#Erendis
echo nameserver 192.168.122.1 > /etc/resolv.conf
apt update
apt install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9
cat <<EOF > /etc/bind/named.conf.local

zone "K22.com" {
    type master;
    file "/etc/bind/zones/db.K22.com";
    allow-transfer { 192.222.3.3; };
};

EOF

mkdir /etc/bind/zones
cat <<EOF > /etc/bind/zones/db.K22.com

$TTL    604800
@       IN      SOA     ns1.K22.com. root.K22.com. (
                        2025102901  ; Serial
                        604800      ; Refresh
                        86400       ; Retry
                        2419200     ; Expire
                        604800 )    ; Negative Cache TTL

; Name servers
@       IN      NS      ns1.K22.com.
@       IN      NS      ns2.K22.com.

; A records (alamat IP)
ns1     IN      A       192.222.3.2   ; Erendis
ns2     IN      A       192.222.3.3   ; Amdir

; Lokasi penting
palantir    IN  A       192.222.4.3
elros       IN  A       192.222.1.6
pharazon    IN  A       192.222.2.2
elendil     IN  A       192.222.1.2
isildur     IN  A       192.222.1.3
anarion     IN  A       192.222.1.4
galadriel   IN  A       192.222.2.6
celeborn    IN  A       192.222.2.5
oropher     IN  A       192.222.2.4


EOF
service bind9 restart
service bind9 status
named-checkzone K22.com /etc/bind/zones/db.K22.com
#Amdir
echo nameserver 192.168.122.1 > /etc/resolv.conf
apt update
apt install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9
cat <<EOF > /etc/bind/named.conf.local

zone "K22.com" {
    type slave;
    masters { 192.222.3.2; };    # IP Erendis
    file "/var/lib/bind/db.K22.com";
};

EOF

service bind9 restart