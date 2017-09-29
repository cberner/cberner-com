---
title: Installing Ubuntu 16.10 on Macbook Pro Retina mid-2012
author: Christopher Berner
type: post
date: 2016-11-27T00:50:46+00:00
url: /2016/11/27/installing-ubuntu-16-10-macbook-pro-retina-mid-2012/
categories:
  - Uncategorized

---
I did a fresh install of 16.10 on my Macbook Pro Retina mid-2012 (rMBP 10,1). It seems quite stable so far, and brings a bunch of small improvements over 16.04.

### Improved from 16.04

1. _Startup Disk Creator can be used for creating the ISO_
2. _Installer works more smoothly_
3. _Nvidia drivers no longer required for good performance_
4. _Intel power management works correctly_

Now for the directions!

## 1. Resize Partitions

This step is pretty straight-forward. Just open Disk Utility in OSX, and resize your existing OSX partition, so that there's some free space for Ubuntu. You'll want to leave the empty space as "free space" (it will get formatted during the Ubuntu installation). There are plenty of guides, if you get stuck on this step, including the [Ubuntu wiki][1].

## 2. Install rEFInd

1. _Download [rEFInd 0.10.3](http://sourceforge.net/projects/refind/files/0.10.3/refind-bin-0.10.3.zip/download)_
2. _Unzip the package._
3. _Run the refind-install script._

If everything went well, you'll see the rEFInd boot menu on the next restart. If you run into any problems, you can find more details on [their website][2].

## 3. Install Ubuntu

Download the Ubuntu 16.10 ISO, and create a bootable USB drive. Note that the wifi won't work (we'll fix this in the next step), so don't try to install updates during the installation process, unless you have a separate usb wifi dongle or ethernet.

## 4. Install Wifi Drivers

Wifi doesn't work out of the box, so from another computer (or your OSX install) [download the driver][3] and its dependencies (dkms, libc6-dev, linux-libc-dev), then copy them all to a flash drive and boot back into Ubuntu. Install each with:

```bash
sudo dpkg -i "the package file you downloaded"
```

Alternatively, if you have a usb wifi card, you can use that and install the driver with this command:

```bash
sudo apt-get update && sudo apt-get install bcmwl-kernel-source
```

## 5. NVIDIA Drivers (optional)

The nouveau drivers work well, but if you want the proprietary drivers which may give better gaming performance, you'll need to install them separately. Open "Additional Drivers" and select the latest proprietary driver.

## 6. Other Configuration (optional)

If you're like me and want the F1-F12 keys to behave as function keys, and not special keys then just follow these steps from the [AppleKeyboard guide](https://help.ubuntu.com/community/AppleKeyboard)

```bash
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all
sudo reboot
```

To increase the text size, since the resolution is very high, open the Displays settings and increase "Scale for menu and title bars".

 [1]: https://help.ubuntu.com/community/MactelSupportTeam/AppleIntelInstallation#Quick_Steps
 [2]: http://www.rodsbooks.com/refind/
 [3]: http://packages.ubuntu.com/yakkety/bcmwl-kernel-source
