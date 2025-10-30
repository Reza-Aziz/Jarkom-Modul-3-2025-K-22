##!/bin/bash
subnet 192.222.1.0 netmask 255.255.255.0 {
    range 192.222.1.6 192.222.1.34;
    range 192.222.1.68 192.222.1.94;
    option routers 192.222.1.1;
    option broadcast-address 192.222.1.255;
    option domain-name-servers 192.222.3.2;
    default-lease-time 1800;   # 30 menit
    max-lease-time 3600;       # 1 jam
}


subnet 192.222.2.0 netmask 255.255.255.0 {
    range 192.222.2.35 192.222.2.67;
    range 192.222.2.96 192.222.2.121;
    option routers 192.222.2.1;
    option broadcast-address 192.222.2.255;
    option domain-name-servers 192.222.3.2;
    default-lease-time 600;    # 10 menit
    max-lease-time 3600;       # 1 jam
}
