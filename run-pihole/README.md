# Run PiHole on your UDM

## Features

1. Run PiHole on your UDM with a completely isolated network stack.  This will not port conflict or be influenced by any changes on by Ubiquiti
2. Persists through reboots and firmware updates.

## Requirements

1. You have successfully setup the on boot script described [here](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)

## Customization

* Feel free to change [20-dns.conflist](../cni-plugins/20-dns.conflist) to change the IP address of the container.
* Update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with your own values
* If you want IPv6 support use [20-dnsipv6.conflist](../cni-plugins/20-dnsipv6.conflist) and update [10-dns.sh](../dns-common/on_boot.d/10-dns.sh) with the IPv6 addresses. Also, please provide IPv6 servers to podman using --dns arguments.

## Steps

1. On your controller, make a Corporate network with no DHCP server and give it a VLAN. For this example we are using VLAN 5.
2. Run the following command adjusting for customizations above
   ```sh
   PIHOLE_PASS="piholeadmin" \
   PIHOLE_TZ="America/Los Angeles" \
   PIHOLE_UPSTREAM_DNS="1.1.1.1" \
   run-pihole.sh root@10.0.0.1 
   ```
3. Update your DNS Servers to 10.0.5.3 (or your custom ip) in all your DHCP configs.
4. Access the pihole like you would normally.
