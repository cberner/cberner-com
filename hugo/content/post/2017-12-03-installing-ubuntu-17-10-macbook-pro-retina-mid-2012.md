---
title: Installing Ubuntu 17.10 on Macbook Pro Retina mid-2012
author: Christopher Berner
type: post
date: 2017-12-03T23:45:00+00:00
url: /2017/12/03/installing-ubuntu-17-10-macbook-pro-retina-mid-2012/
categories:
  - Ubuntu

---
I skipped 17.04, since it didn't seem to add much that I was excited about, but 17.10 has switched from Unity back to Gnome3, so I wanted to give it a try. I did a fresh install of 17.10 on my Macbook Pro Retina mid-2012 (rMBP 10,1). It continues to simplify the installation process, and seems quite stable so far.

### Improved from 16.10

1. _No longer need to use rEFInd_
2. _Hi-DPI scaling!_

Now for the directions!

## 1. Resize OSX Partition

This step is pretty straight-forward. Just open Disk Utility in OSX, and resize your existing OSX partition, so that there's some free space for Ubuntu. You'll want to leave the empty space as "free space" (it will get formatted during the Ubuntu installation). There are plenty of guides, if you get stuck on this step, including the [Ubuntu wiki][1].

## 2. Install Ubuntu

* Download the Ubuntu 17.10 ISO, and create a bootable USB drive.
* Insert the USB, and hold 'option' key while booting. Select the USB drive to boot from.
* Select "Try Ubuntu" (not "Install Ubuntu") from the menu.
* Once it boots to the Ubuntu Desktop Open the "Install Ubuntu" icon and follow the installation instructions. Note that the wifi won't work (we'll fix this in the next step), so don't try to install updates during the installation process, unless you have a separate usb wifi dongle or ethernet.

## 3. Install Wifi Drivers

Wifi doesn't work out of the box, so from another computer (or your OSX install) [download the driver][2] and its dependencies (dkms, libc6-dev, linux-libc-dev), then copy them all to a flash drive and boot back into Ubuntu. Install each with:

```bash
sudo dpkg -i "the package file you downloaded"
```

Alternatively, if you have a usb wifi card, you can use that and install the driver with this command:

```bash
sudo apt-get update && sudo apt-get install bcmwl-kernel-source
```

## 4. NVIDIA Drivers (optional)

The nouveau drivers work well, but if you want the proprietary drivers which may give better gaming performance, you'll need to install them separately. Open "Software & Updates" then go to the "Additional Drivers" tab and select the latest proprietary driver.

## 5. Other Configuration (optional)

If you're like me and want the F1-F12 keys to behave as function keys, and not special keys then just follow these steps from the [AppleKeyboard guide](https://help.ubuntu.com/community/AppleKeyboard)

```bash
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all
sudo reboot
```

 [1]: https://help.ubuntu.com/community/MactelSupportTeam/AppleIntelInstallation#Quick_Steps
 [2]: http://packages.ubuntu.com/artful/bcmwl-kernel-source
