#Erendis
cat <<EOF > /etc/bind/zones/db.K22.com

www     IN      CNAME   K22.com.

EOF

cat <<EOF > /etc/bind/zones/db.192.222.3
;
; Reverse zone for network 192.222.3.0/24
;
$TTL    604800
@       IN      SOA     ns1.K22.com. root.K22.com. (
                        2025102901  ; Serial
                        604800      ; Refresh
                        86400       ; Retry
                        2419200     ; Expire
                        604800 )    ; Negative Cache TTL
;
@       IN      NS      ns1.K22.com.
@       IN      NS      ns2.K22.com.

2       IN      PTR     Erendis.K22.com.
3       IN      PTR     Amdir.K22.com.
EOF

cat <<EOF > /etc/bind/named.conf.local

zone "3.222.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.222.3";
};

EOF

cat <<EOF > /etc/bind/zones/db.K22.com

"Cincin_Sauron"      IN      TXT     "Elros"
"Aliansi_Terakhir"   IN      TXT     "Pharazon"

EOF
service bind9 restart

#Amdir
cat <<EOF > /etc/bind/named.conf.local

zone "3.222.192.in-addr.arpa" {
    type slave;
    masters { 192.222.3.2; };
    file "/var/lib/bind/db.192.222.3";
};
EOF