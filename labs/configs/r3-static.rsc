# RouterOS v7 isolated CHR lab only
/system identity set name=R3
/interface bridge add name=lo protocol-mode=none
/interface bridge add name=br-lan protocol-mode=rstp
/interface bridge port add bridge=br-lan interface=ether3
/ip address add address=10.255.0.3/32 interface=lo comment="loopback"
/ip address add address=10.0.23.2/30 interface=ether2 comment="R3-R2"
/ip address add address=192.168.30.1/24 interface=br-lan comment="R3 LAN"
/ip route add dst-address=192.168.10.0/24 gateway=10.0.23.1 comment="HQ via R2"
