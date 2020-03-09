#!/bin/sh

ssh -p 2222 root@138.68.182.52 /bin/sh -ex << EOF
cd /usr/src/netdata.git
git pull -q
cat packaging/installer/kickstart.sh > /usr/share/netdata/web/kickstart.sh
cat packaging/installer/kickstart-static64.sh > /usr/share/netdata/web/kickstart-static64.sh
EOF
