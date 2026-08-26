# RouterOS v7 isolated CHR lab only
/system identity set name=R1
/interface bridge add name=lo protocol-mode=none
/interface bridge add name=br-lan protocol-mode=rstp
/interface bridge port add bridge=br-lan interface=ether3
/ip address add address=10.255.0.1/32 interface=lo comment="loopback"
/ip address add address=10.0.12.1/30 interface=ether2 comment="R1-R2"
/ip address add address=192.168.10.1/24 interface=br-lan comment="R1 LAN"
/ip route add dst-address=192.168.30.0/24 gateway=10.0.12.2 comment="branch via R2"
