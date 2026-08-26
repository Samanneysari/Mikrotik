# Apply after r2-static.rsc, then disable/remove matching static LAN routes
/routing ospf instance add name=ospf-v2 version=2 router-id=10.255.0.2
/routing ospf area add name=backbone area-id=0.0.0.0 instance=ospf-v2
/routing ospf interface-template add area=backbone networks=10.0.12.0/30 type=ptp
/routing ospf interface-template add area=backbone networks=10.0.23.0/30 type=ptp
/routing ospf interface-template add area=backbone networks=10.255.0.2/32 passive=yes
