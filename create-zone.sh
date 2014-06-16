ZONE=test
IPPE=zn_csw0
BASE=template
ZPATH=/zones/$ZONE
ZIP=172.16.0.33
ZNM=255.255.255.0
ZGW=172.16.0.1
ZDNS=172.16.0.1,172.16.0.2
ZDOMAIN=home.intra
ZSEARCH=home.intra
ROOTPW=your.root.password
TMPFILE=$(mktemp)

# Warning: Your host, and it's reverse should be set in your dns, and it's reverse should match!

cat <<END >$TMPFILE
create
set autoboot=true
set zonepath=$ZPATH
set ip-type=exclusive
add net
set physical=zn_template0
end
verify
exit
END

zonecfg -z $ZONE -f $TMPFILE
rm $TMPFILE

zoneadm -z $ZONE clone $BASE

cat <<END >${ZPATH}/root/etc/sysidcfg
terminal=xterm
network_interface=PRIMARY {hostname=$ZONE
ip_address=$ZIP
netmask=$ZNM
protocol_ipv6=no
default_route=$ZGW}
security_policy=none
name_service=DNS
{domain_name=$ZDOMAIN
name_server=$ZDNS
search=$ZSEARCH}
nfs4_domain=dynamic
timezone=Europe/Budapest
root_password=$(echo "$ROOTPW" | openssl passwd -crypt -stdin)
END

zoneadm -z $ZONE boot
zlogin -C $ZONE
