#!/bin/sh
#

if [ -L /usr/bin/mDNS -o ! -e /usr/bin/mDNS ]; then
    # If it is a symlink or it doesn't exist, defer to the dns-sd command
    HNAME=$(dns-sd -L "$1"  _tivo-videos._tcp local | grep 'can be reached.*:443' | colrm 1 78 | awk -F: '{print $1}' | sed 's@\.$@@' | sort | uniq | head -1 &
    sleep 2
    killall dns-sd)
    ping -c 1 ${HNAME} | head -1 | cut -d \( -f 2 | cut -d \) -f 1
else
    # Go ahead and use the mDNS executable
    IP_ADDRESS=$(mDNS -L "$1" _tivo-videos._tcp local | grep ':443' | colrm 1 42 | awk '{print $1}' | sort | uniq | head -1 &
    sleep 2
    killall mDNS)
    echo ${IP_ADDRESS}
fi
