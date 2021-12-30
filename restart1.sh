#!/bin/sh
#
# Restart running wireguard clients
#
PATH=/bin:/sbin:/usr/bin:/usr/sbin

IFACE="$1"
ACTION="$2"

# Ensure that this connection is _not_ a Wireguard connection. Without this check
# Wireguard would get into a restart loop, because its interface is also a
# NetworkManager connection and would trigger its own "up" action.
if echo $IFACE|grep -qE '^wlp2s0$'; then
    if [ "$ACTION" = "up" ]; then
        ls /etc/wireguard/*.conf|while read CONFIG; do
            IFACE=`basename $CONFIG .conf`
            if ip addr show $IFACE > /dev/null 2>&1; then
                wg-quick down $IFACE
                wg-quick up $IFACE
            fi
        done
    fi
fi