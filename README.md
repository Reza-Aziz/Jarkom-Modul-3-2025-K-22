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

> Tujuan: Bagi IP otomatis ke node sesuai subnet.

> Langkah

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

> Tujuan: Semua lalu lintas ke internet harus lewat Minastir, kecuali Durin boleh langsung.

> Langkah

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

> Tujuan: Pastikan semua node bisa saling komunikasi antar subnet.

> Langkah
