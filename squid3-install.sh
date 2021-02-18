echo "Installing..."
    /usr/bin/apt update
    /usr/bin/apt -y install apache2-utils squid3
    touch /etc/squid/passwd
    /bin/rm -f /etc/squid/squidleoh.conf
    /usr/bin/touch /etc/squid/blacklist.acl
    /usr/bin/wget --no-check-certificate -O /etc/squid/squidleoh.conf https://raw.githubusercontent.com/leohturbo/squid/master/squidleoh.conf
    /sbin/iptables -I INPUT -p tcp --dport 3128 -j ACCEPT
    /sbin/iptables-save
    service squid restart
    systemctl enable squid
echo "Installed! =)"

echo "Running IP updates."

IP_ALL=$(/sbin/ip -4 -o addr show scope global | awk '{gsub(/\/.*/,"",$4); print $4}')

IP_ALL_ARRAY=($IP_ALL)

SQUID_CONFIG="\n"

for IP_ADDR in ${IP_ALL_ARRAY[@]}; do
    ACL_NAME="proxy_ip_${IP_ADDR//\./_}"
    SQUID_CONFIG+="acl ${ACL_NAME}  myip ${IP_ADDR}\n"
    SQUID_CONFIG+="tcp_outgoing_address ${IP_ADDR} ${ACL_NAME}\n\n"
done

echo "Updating squid config"

echo -e $SQUID_CONFIG >> /etc/squid/squid.conf

echo "Restarting squid..."

systemctl restart squid

echo "Done"
