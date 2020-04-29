mkdir /netdata-source
cd /netdata-source
git clone https://github.com/amoss/netdata.git fork.git
cd fork.git
git fetch
git checkout reneg-fix
CFLAGS="-O1 -ggdb -DNETDATA_INTERNAL_CHECKS" ./netdata-installer.sh --dont-wait --require-cloud
if [ -e /etc/netdata/claim.d/claimed_id ]; then
    echo "Already claimed"
else
    systemctl stop netdata
    echo >>/etc/netdata/netdata.conf "[global]"
    echo >>/etc/netdata/netdata.conf "debug flags = 0x0000000200000000"
    netdata-claim.sh -token=GmN_5PwFNguvmPkjWNipOVokIpjCkGGbp6utcEYf9hRr2hGEFJN__PAJ6s8eVy_A33adqtuk8EOLhcUMfMbgHIkV5hj4VV6WONmSdXkaM2ziOPbCzqDfDcWE8D9cgONY5Vk-8sE -rooms=948e5499-371a-4424-9a98-63e6db114bce -url=https://staging.netdata.cloud
    systemctl start netdata
fi
sed -i -e 's/.*log flood protection.*/ log flood protection = 0/' /etc/netdata/netdata.conf
