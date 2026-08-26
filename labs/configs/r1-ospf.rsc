# Apply after r1-static.rsc, then disable/remove matching static branch route
/routing ospf instance add name=ospf-v2 version=2 router-id=10.255.0.1
/routing ospf area add name=backbone area-id=0.0.0.0 instance=ospf-v2
/routing ospf interface-template add area=backbone networks=10.0.12.0/30 type=ptp
/routing ospf interface-template add area=backbone networks=10.255.0.1/32 passive=yes
/routing ospf interface-template add area=backbone networks=192.168.10.0/24 passive=yes
