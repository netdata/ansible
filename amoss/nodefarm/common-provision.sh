mkdir /netdata-source
cd /netdata-source
git clone https://github.com/netdata/netdata.git fork.git
#git clone https://github.com/amoss/netdata.git fork.git
cd fork.git
git fetch
git fetch origin refs/pull/8916/head
git checkout -b prologic/ubuntu_1404_support FETCH_HEAD
#git checkout reneg-fix
CFLAGS="-O1 -ggdb -DNETDATA_INTERNAL_CHECKS" ./netdata-installer.sh --dont-wait --require-cloud
if [ -e /etc/netdata/claim.d/claimed_id ]; then
    echo "Already claimed"
else
    systemctl stop netdata
    echo >>/etc/netdata/netdata.conf "[global]"
    echo >>/etc/netdata/netdata.conf "debug flags = 0x0000000200000000"
    netdata-claim.sh -token=ui7FyuDuLu5O7B6w1JskhgbIR2Y59JtfK6NyxzNOlg7oaTTPboWrD4KSF53EZ8TtspZJCugoVStjDnNvhP9db3nMW1FRbXAt2Aofkonp9r4Npi9YJCnojVUuiKpFD6-ev1o-HwA -rooms=36eef934-c0ae-43e2-9da3-fc5f3c5f0dfb -url=https://app.netdata.cloud
    systemctl start netdata
fi
sed -i -e 's/.*log flood protection.*/ log flood protection = 0/' /etc/netdata/netdata.conf
