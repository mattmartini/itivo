#!/bin/sh
#

if [ -L /usr/bin/mDNS -o ! -e /usr/bin/mDNS ]; then
    # If it is a symlink or it doesn't exist, defer to the dns-sd command
    # Sample output: "21:29:27.751  Add     2  5 local.                    _tivo-videos._tcp.        HD Living Room"
    dns-sd -B _tivo-videos._tcp local | colrm 1 79 | grep -v 'Instance Name' | sort | uniq &
    sleep 2
    killall dns-sd
else
    # Go ahead and use the mDNS executable
    # Sample output: "21:29:33.402  Add     1 local.                   _tivo-videos._tcp.       HD Living Room"
    mDNS -B _tivo-videos._tcp local | colrm 1 74 | grep -v 'Instance Name' | sort | uniq &
    sleep 2
    killall mDNS
fi


