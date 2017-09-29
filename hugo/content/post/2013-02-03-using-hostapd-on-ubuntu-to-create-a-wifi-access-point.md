---
title: Using hostapd on Ubuntu to create a wifi access point
author: Christopher Berner
type: post
date: 2013-02-04T01:01:50+00:00
url: /2013/02/03/using-hostapd-on-ubuntu-to-create-a-wifi-access-point/
categories:
  - Robotics
  - Ubuntu

---
I've been working on an autonomous hexacopter, which has a Pandaboard ES running Ubuntu on it, and I wanted it to setup its own wifi network in the field for easy ssh access. Turns out this is pretty simple to do, but you need to configure several different daemons to get it working right.

## 1. Check your wifi card

You'll need a wifi card that supports [master mode](https://help.ubuntu.com/community/WifiDocs/MasterMode), if you're going to create an access point with it. First, figure out what your wifi card is named (look for one starting with 'wlan')

```bash
ifconfig
```

Next, check if "AP" mode is supported

```bash
iw list
```

and look for something like:

```
...
Supported interface modes:
         * IBSS
         * managed
         * AP
...
```

On some drivers you can also check for master mode with iwconfig:

```bash
sudo iwconfig  mode master
```

## 2. Setup hostapd

Assuming your wifi card supports master mode, the next step is to setup hostapd

```bash
sudo apt-get install hostapd
```

Now create the file /etc/hostapd/hostapd.conf with the follow content: (if you want to use 5Ghz instead of 2.4Ghz, use `hw_mode=a` and `channel=149` instead)

```text
interface=wlan0
driver=nl80211
ssid=my_ap
hw_mode=g
channel=6
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=3
wpa_passphrase=my_password
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

Finally, edit /etc/default/hostapd to have the line:

```
DAEMON_CONF=/etc/hostapd/hostapd.conf
```

## 3. Setup dnsmasq

Now, it's time to setup dnsmasq to handle DHCP and DNS on our wifi network, otherwise your clients won't be able to get an IP address.

```bash
sudo apt-get install dnsmasq
```

Next, edit the dnsmasq configuration file to include this:

```text
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.10,255.255.255.0,12h
no-hosts
addn-hosts=/etc/hosts.dnsmasq
```

We set 'no-hosts' to avoid including all the entries in your hosts file in the DNS server, and instead set a separate file that will configure the DNS mapping for the machine hosting the AP. Make sure to create the file /etc/hosts.dnsmasq with the name of your computer:

```
10.0.0.1 my_hostname
```

## 4. Modify /etc/network/interfaces

Add these lines to your /etc/network/interfaces file, to give it a static IP address:

```text
auto wlan0
iface wlan0 inet static
address 10.0.0.1
netmask 255.255.255.0
```

## 5. Troubleshooting

If you have network-manager configured to use your wifi card, you should disable auto-connect for all the wireless connections. Otherwise, it may interfere with hostapd. If some frequencies are disabled, make sure your driver is set to use the right regulatory domain. You can see the current one with:

```bash
iw reg get
```

If it says "country 00", you need to set it manually, in /etc/default/crda. To set it manually you need (at least for some cards) to have cfg80211 and mac80211 installed as kernel modules. You can check if they're installed as modules by using

```bash
zcat /proc/config.gz
```

Look for `CONFIG_CFG80211=m`, if it says "=y" then it's compiled into the kernel, and you'll need to re-install your kernel. If you're using an Atheros card, you may also need to set the region in the driver. Do this by adding `cfg80211 ieee80211_regdom=US` to /etc/modules

