# Laporan Resmi Praktikum Komunikasi Data dan Jaringan Komputer Modul 3

# Jarkom K22

## Member

| No  | Nama                   | NRP        |
| --- | ---------------------- | ---------- |
| 1   | Kanafira Vanesha Putri | 5027241010 |
| 2   | Reza Aziz Simatupang   | 5027241051 |

## Reporting

### Soal 1

> Di awal Zaman Kedua, setelah kehancuran Beleriand, para Valar menugaskan untuk membangun kembali jaringan komunikasi antar kerajaan. Para Valar menyalakan Minastir, Aldarion, Erendis, Amdir, Palantir, Narvi, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher, Miriel, Amandil, Gilgalad, Celebrimbor, Khamul, dan pastikan setiap node (selain Durin sang penghubung antar dunia) dapat sementara berkomunikasi dengan Valinor/Internet (nameserver 192.168.122.1) untuk menerima instruksi awal.

### **Soal 2**

> Raja Pelaut Aldarion, penguasa wilayah Númenor, memutuskan cara pembagian tanah client secara dinamis. Ia menetapkan:
>
> - Client Dinamis Keluarga Manusia: Mendapatkan tanah di rentang `[prefix ip].1.6` - `[prefix ip].1.34` dan `[prefix ip].1.68` - `[prefix ip].1.94`.
> - Client Dinamis Keluarga Peri: Mendapatkan tanah di rentang `[prefix ip].2.35` - `[prefix ip].2.67` dan `[prefix ip].2.96` - `[prefix ip].2.121`.
> - Khamul yang misterius: Diberikan tanah tetap di `[prefix ip].3.95`, agar keberadaannya selalu diketahui.
>
> Pastikan **Durin** dapat menyampaikan dekrit ini ke semua wilayah yang terhubung dengannya.

Tujuan: Bagi IP otomatis ke node sesuai subnet.

Langkah

- Di Aldarion (DHCP Server)

```c
apt install isc-dhcp-server -y
```

- Lalu masukkan config ini pada .bashrc agar auto

```c
echo 'INTERFACESv4="eth1 eth2 eth3 eth4 eth5"' > /etc/default/isc-dhcp-server

cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.222.1.0 netmask 255.255.255.0 {
    range 192.222.1.6 192.222.1.34;
    range 192.222.1.68 192.222.1.94;
    option routers 192.222.1.1;
    option broadcast-address 192.222.1.255;
    option domain-name-servers 192.168.122.1;
    default-lease-time 1800;
    max-lease-time 3600;
}

subnet 192.222.2.0 netmask 255.255.255.0 {
    range 192.222.2.35 192.222.2.67;
    range 192.222.2.96 192.222.2.121;
    option routers 192.222.2.1;
    option broadcast-address 192.222.2.255;
    option domain-name-servers 192.168.122.1;
    default-lease-time 600;
    max-lease-time 3600;
}

subnet 192.222.3.0 netmask 255.255.255.0 {
    option routers 192.222.3.1;
    option broadcast-address 192.222.3.255;
    option domain-name-servers 192.168.122.1;
}

subnet 192.222.4.0 netmask 255.255.255.0 {
    range 192.222.4.2 192.222.4.254;
    option routers 192.222.4.1;
    option broadcast-address 192.222.4.255;
    option domain-name-servers 192.168.122.1;
}

subnet 192.222.5.0 netmask 255.255.255.0 {
    range 192.222.5.2 192.222.5.254;
    option routers 192.222.5.1;
    option broadcast-address 192.222.5.255;
    option domain-name-servers 192.168.122.1;
}

host khamul {
    fixed-address 192.222.3.95;
}
EOF

service isc-dhcp-server restart
```

- Lalu pada Durin (DHCP Relay)

```c
apt install isc-dhcp-relay -y
```

lalu edit bagian 

```c
nano /etc/default/isc-dhcp-relay
```

isi dengan 

```c
SERVERS="192.222.1.2"   # IP Aldarion
INTERFACES="eth1 eth2 eth3 eth4 eth5"
OPTIONS=""
```

lalu restart

```c
service isc-dhcp-relay restart
```

### **Soal 3**

> Untuk mengontrol arus informasi ke dunia luar (Valinor/Internet), sebuah menara pengawas, **Minastir** didirikan. Minastir mengatur agar semua node (kecuali Durin) hanya dapat mengirim pesan ke luar Arda setelah melewati pemeriksaan di Minastir.

Tujuan: Semua lalu lintas ke internet harus lewat Minastir, kecuali Durin boleh langsung.

Langkah

- Pada Minastir, tambahkan script untuk firewall

```c
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT

# Blok semua node kecuali Durin ke internet langsung
iptables -A OUTPUT -o eth0 -s 192.222.0.0/16 -j DROP
iptables -A OUTPUT -o eth0 -s 192.222.3.95 -j ACCEPT  # IP Durin

# Simpan di bashrc biar otomatis
cat <<EOF >> ~/.bashrc
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o eth0 -s 192.222.0.0/16 -j DROP
iptables -A OUTPUT -o eth0 -s 192.222.3.95 -j ACCEPT
EOF
```

> Test
- Dari node biasa → `ping 8.8.8.8` (harus lewat Minastir)
- Dari Durin → `ping 8.8.8.8` (langsung tembus)

### **Soal 4**

> Ratu Erendis, sang pembuat peta, menetapkan nama resmi untuk wilayah utama (`K55.com`). Ia menunjuk dirinya (`ns1.K55.com`) dan muridnya Amdir (`ns2.K55.com`) sebagai penjaga peta resmi. Setiap lokasi penting (Palantir, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher) diberikan nama domain unik yang menunjuk ke lokasi fisik tanah mereka. Pastikan Amdir selalu menyalin peta (_master-slave_) dari Erendis dengan setia.

Tujuan: Pastikan semua node bisa saling komunikasi antar subnet.

Langkah

- Di Durin (Router utama):

```c
echo 1 > /proc/sys/net/ipv4/ip_forward
```

lalu tambahkan .bashrc agar auto

```c
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> ~/.bashrc
```

Kalau ada router tambahan (misal Minastir juga routing), tambahkan route manual:

```c
ip route add 192.222.1.0/24 via 192.222.3.1
ip route add 192.222.2.0/24 via 192.222.3.1
```

### **Soal 5**

> Untuk memudahkan, nama alias `www.K55.com` dibuat untuk peta utama `K55.com`. **Reverse PTR** juga dibuat agar lokasi Erendis dan Amdir dapat dilacak dari alamat fisik tanahnya. Erendis juga menambahkan pesan rahasia (**TXT record**) pada petanya: "Cincin Sauron" yang menunjuk ke lokasi Elros, dan "Aliansi Terakhir" yang menunjuk ke lokasi Pharazon. Pastikan Amdir juga mengetahui pesan rahasia ini.

Tujuan: 

Langkah

- Add cname (erendis)

```c
nano /etc/bind/zones/db.K22.com

www     IN      CNAME   K22.com

nano /etc/bind/zones/db.192.222.3

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

nano /etc/bind/named.conf.local
zone "3.222.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.222.3";
};

nano  /etc/bind/zones/db.K22.com

"Cincin_Sauron"      IN      TXT     "Elros"
"Aliansi_Terakhir"   IN      TXT     "Pharazon"

service bind9 restart
```

- Amdir

```c
nano /etc/bind/named.conf.local

zone "3.222.192.in-addr.arpa" {
    type slave;
    masters { 192.222.3.2; };
    file "/var/lib/bind/db.192.222.3";
};
```

### **Soal 6**

> Aldarion menetapkan aturan waktu peminjaman tanah. Ia mengatur:
>
> - Client Dinamis Keluarga Manusia dapat meminjam tanah selama **setengah jam**.
> - Client Dinamis Keluarga Peri hanya **seperenam jam**.
> - Batas waktu maksimal peminjaman untuk semua adalah **satu jam**.


Tujuan:

Langkah

```c
# Subnet untuk Client Dinamis Keluarga Manusia
subnet 192.222.1.0 netmask 255.255.255.0 {
    range 192.222.1.6 192.222.1.34;
    range 192.222.1.68 192.222.1.94;
    option routers 192.222.1.1;
    option broadcast-address 192.222.1.255;
    option domain-name-servers 192.222.3.2;
    default-lease-time 1800;   # 30 menit
    max-lease-time 3600;       # 1 jam
}

# Subnet untuk Client Dinamis Keluarga Peri
subnet 192.222.2.0 netmask 255.255.255.0 {
    range 192.222.2.35 192.222.2.67;
    range 192.222.2.96 192.222.2.121;
    option routers 192.222.2.1;
    option broadcast-address 192.222.2.255;
    option domain-name-servers 192.222.3.2;
    default-lease-time 600;    # 10 menit
    max-lease-time 3600;       # 1 jam
}
```

### **Soal 7**

> Para Ksatria Númenor (Elendil, Isildur, Anarion) mulai membangun benteng pertahanan digital mereka menggunakan teknologi Laravel. Instal semua _tools_ yang dibutuhkan (`php8.4`, `composer`, `nginx`) dan dapatkan cetak biru benteng dari `Resource-laravel` di setiap node _worker_ Laravel. Cek dengan `lynx` di client.

Tujuan:

Langkah

- bashrc masing” node

```c
echo nameserver 192.168.122.1 > /etc/resolv.conf
apt update && apt install -y php8.4 php8.4-cli php8.4-fpm php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip php8.4-sqlite3 php8.4-mysql nginx git unzip curl && curl -sS https://getcomposer.org/installer | php
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api laravel
```

- Install dependensi di node Laravel (Elendil, Isildur, Anarion)

```c
apt update
apt install -y php8.4 php8.4-cli php8.4-fpm php8.4-mbstring php8.4-xml php8.4-curl php8.4-zip php8.4-sqlite3 php8.4-mysql nginx git unzip curl
apt install nginx -y
```

- Lalu install Composer:

```c
cd ..
cd .. 
cd root
mv composer.phar /usr/local/bin/composer
```

- masuk lagi ke dir laravel

```c
cd /var/www/laravel
```

- Install Laravel dependencies

```c
composer config platform.php 8.2.0 && composer update --no-scripts && composer install
```

- Lalu copy file environment:

```c
cp .env.example .env && php artisan key:generate
```

- Lalu atur permission

```c
chown -R www-data:www-data /var/www/laravel && chmod -R 755 /var/www/laravel
```

- Lalu lakukan config nginx nya

```c
nano /etc/nginx/sites-available/laravel

#Config
server {
    listen 8001;
    server_name elendil.K22.com;

    root /var/www/laravel/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /var/log/nginx/laravel_access.log;
    error_log /var/log/nginx/laravel_error.log;
}
```

- Lalu aktifkan sitenya

```c
ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/ && nginx -t && service nginx restart && service php8.4-fpm restart
```

Test

```c
lynx http://elendil.K22.com
```

### **Soal 8**

> Setiap benteng Númenor harus terhubung ke sumber pengetahuan, **Palantir**. Konfigurasikan koneksi database di file **.env** masing-masing worker. Setiap benteng juga harus memiliki gerbang masuk yang unik; atur nginx agar **Elendil mendengarkan di port 8001, Isildur di 8002, dan Anarion di 8003**. Jangan lupa jalankan **migrasi dan seeding** awal dari **Elendil**. Buat agar akses web hanya bisa melalui **domain nama**, tidak bisa melalui ip.

Tujuan:

Langkah

- Pertama lakukan installasi

```c
apt update && apt install -y mariadb-server mariadb-client
```

Lalu start mariadb dan masuk ke sql di palantir

```c
service mariadb start && mariadb

CREATE DATABASE laravel;

CREATE DATABASE laravel;

GRANT ALL PRIVILEGES ON laravel.* TO 'laraveluser'@'%';

FLUSH PRIVILEGES;

exit;
```

- Lalu lakukan akses dari luar

```c
nano /etc/mysql/mariadb.conf.d/50-server.cnf

#cari
bind-address = 127.0.0.1
#rubah ke
bind-address = 0.0.0.0

service mariadb restart
```

- cek pastikan mariaDB listen

```c
ss -tuln | grep 3306
```

Test di  node elendil

```c
mysql -h 192.222.4.3 -u laraveluser -p
```

- Lakukan konfigurasi pada Worker

Pada tiap worker “elendil,anarion, isildur” masuk ke directory laravel 

```c
cd /var/www/laravel

chown -R www-data:www-data /var/www/laravel && chmod -R 755 /var/www/laravel
```

edit file .env pada tiap-tiap worker

```c
nano /var/www/laravel/.env

DB_CONNECTION=mysql
DB_HOST=192.222.4.3        # IP Palantir
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laraveluser
DB_PASSWORD=rootpass
```

migrasi & seeding (hanya di node elendil)

```c
php artisan migrate:fresh

php artisan db:seed --class=AiringsTableSeeder
```

- Lakukan config nginx pada tiap worker

Pertama nyalakan servicenya

```c
nano /etc/nginx/sites-available/laravel
```

```c
service nginx restart
```

- Lalu pada masing-masing node worker 

Atur nginx agar listen pada tiap-tiap port

```c
nano /etc/nginx/sites-available/elendil

server {
    listen 8001;
    server_name elendil.K22.com
    if ($host ~* "^[0-9.]+$") {
        return 444;
    }

    root /var/www/laravel/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

- Aktifkan dan reload nginx pada tiap-tiap worker

```c
server {
    listen 8001;
    server_name elendil.K22.com
    if ($host ~* "^[0-9.]+$") {
        return 444;
    }

    root /var/www/laravel/public;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
```

Test 

```c
netstat -tulpn | grep nginx
```

- Masukkan pada klien yang ingin dilakukan lynx untuk testing

```c
nano /etc/hosts

192.222.1.2   elendil.k22.com
192.222.1.3   Isildur.k22.com
192.222.1.4   Anarion.k22.com

```

### **Soal 9**

> Pastikan setiap benteng berfungsi secara mandiri. Dari dalam node client masing-masing, gunakan `lynx` untuk melihat halaman utama Laravel dan `curl /api/airing` untuk memastikan mereka bisa mengambil data dari Palantir.

Tujuan:

Langkah

- Install pada client

```
apt update && apt install -y lynx curl
```

- Pastikan DNS mengarah ke server yang benar

```c
sudo nano /etc/resolv.conf

nameserver 192.168.122.1
nameserver 192.222.3.2 #IP erendis
nameserver 192.222.3.3 #IP Amdir
```

- Lalu coba test tiap benteng pada client

```c
lynx -dump http://elendil.k22.com:8001
lynx -dump http://isildur.k22.com:8002
lynx -dump http://anarion.k22.com:8003
```

### **Soal 10: Penyampaian Ulang**

> Pemimpin bijak Elros ditugaskan untuk mengkoordinasikan pertahanan Númenor. Konfigurasikan nginx di **Elros** untuk bertindak sebagai **reverse proxy**. Buat _upstream_ bernama **kesatria_numenor** yang berisi alamat ketiga _worker_ (Elendil, Isildur, Anarion). Atur agar semua permintaan yang datang ke domain **elros.K55.com** diteruskan secara merata menggunakan algoritma **Round Robin** ke _backend_.

Tujuan:

Langkah

- Pertama lakukan instalasi pada nginx (elros)
```c
apt install nginx -y
```

- Lalu buat file config baru

```c
nano /etc/nginx/sites-available/elros.k22.com

# === Reverse Proxy / Load Balancer Elros ===

# Daftar backend (worker)
upstream kesatria_numenor {
    server elendil.k22.com:8001;
    server isildur.k22.com:8002;
    server anarion.k22.com:8003;
}

server {
    listen 80;
    server_name elros.k22.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- Lalu aktifkan konfigurasi 

```c
ln -s /etc/nginx/sites-available/elros.k22.com /etc/nginx/sites-enabled/ && rm /etc/nginx/sites-enabled/default
```

- Lalu cek konfigurasi dan reload nginx nya

```c
nginx -t && service nginx reload
```

- Tambahkan ip eros pada client yang akan melakukan curl
```c
nano /etc/hosts

#Tambahkan
192.222.1.6   elros.k22.com
```
- Cek dari client

```c
curl http://elros.k22.com/api/airing
```