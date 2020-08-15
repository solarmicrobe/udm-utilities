#!/usr/bin/env sh

PIHOLE_PASS=${PIHOLE_PASS:-"piholeadmin"}
PIHOLE_TZ=${PIHOLE_TZ:-"America/Chicago"}
PIHOLE_UPSTREAM_DNS=${PIHOLE_UPSTREAM_DNS:-1.1.1.1}

echo "Script executed from: ${PWD}"

BASEDIR=$(dirname $0)
echo "Script location: ${BASEDIR}"

ssh -q "$1" ls -d /mnt/data/on_boot.d/ > /dev/null

EC=$?

if [ ${EC} -eq 255 ]; then
  echo "Failure to connect to ssh host"
  exit 1
elif [ ${EC} -gt 0 ]; then
  echo "/mnt/data/on_boot.d/ does not exist, are you sure you've already installed https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script" && exit 1
fi

{ scp -q ${BASEDIR}/../dns-common/on_boot.d/10-dns.sh $1:/mnt/data/on_boot.d/10-dns.sh && echo "Copied 10-dns.sh"; } || { echo "Failed to copy 10-dns.sh"; exit 1; }
{ ssh -q "$1" /mnt/data/on_boot.d/10-dns.sh && echo "Executed 10-dns.sh"; } || { echo "Failed to execute 10-dns.sh"; exit 1; }

{ scp ${BASEDIR}/../cni-plugins/20-dns.conflist $1:/mnt/data/podman/cni/20-dns.conflist; echo "Copied 20-dns.conflist"; } || { echo "Failed to copy 20-dns.conflist"; exit 1; }

{ ssh -q "$1" mkdir -p /mnt/data/etc-pihole/  && echo "Ensuring /mnt/data/etc-pihole/ exists"; } || { echo "Could not create /mnt/data/etc-pihole/" && exit 1; }
{ ssh -q "$1" mkdir -p /mnt/data/pihole/etc-dnsmasq.d/  && echo "Ensuring /mnt/data/pihole/etc-dnsmasq.d/ exists"; } || { echo "Could not create /mnt/data/pihole/etc-dnsmasq.d/" && exit 1; }

ssh -q "$1" 'podman stop pihole && podman rm pihole'
ssh -q "$1" <<EOF
     podman run -d --network dns --restart always \
        --name pihole \
        -e WEBPASSWORD="${PIHOLE_PASS}" \
        -e TZ="${PIHOLE_TZ}" \
        -e VIRTUAL_HOST="pi.hole" \
        -e PROXY_LOCATION="pi.hole" \
        -e ServerIP="10.0.5.3" \
        -e IPv6="False" \
        -v "/mnt/data/etc-pihole/:/etc/pihole/" \
        -v "/mnt/data/pihole/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
        --dns=127.0.0.1 --dns=${PIHOLE_UPSTREAM_DNS} \
        --hostname pi.hole \
        pihole/pihole:latest
EOF