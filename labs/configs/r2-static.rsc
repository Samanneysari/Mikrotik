# RouterOS v7 isolated CHR lab only
/system identity set name=R2
/interface bridge add name=lo protocol-mode=none
/ip address add address=10.255.0.2/32 interface=lo comment="loopback"
/ip address add address=10.0.12.2/30 interface=ether2 comment="R2-R1"
/ip address add address=10.0.23.1/30 interface=ether3 comment="R2-R3"
/ip address add address=198.51.100.1/30 interface=ether4 comment="R2-ISP lab"
/ip route add dst-address=192.168.10.0/24 gateway=10.0.12.1 comment="HQ via R1"
/ip route add dst-address=192.168.30.0/24 gateway=10.0.23.2 comment="branch via R3"
