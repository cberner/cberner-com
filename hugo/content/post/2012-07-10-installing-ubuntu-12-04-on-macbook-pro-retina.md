---
title: Installing Ubuntu 12.04 on Macbook Pro Retina (10,1)
author: Christopher Berner
type: post
date: 2012-07-10T22:09:08+00:00
url: /2012/07/10/installing-ubuntu-12-04-on-macbook-pro-retina/
categories:
  - Ubuntu

---
## 1. Install rEFIt

1. _Download and mount the [rEFIt-0.14.dmg](http://prdownloads.sourceforge.net/refit/rEFIt-0.14.dmg?download) disk image._
2. _Double-click on the "rEFIt.mpkg" package._
3. _Follow the instructions and select your Mac OS X installation volume as the destination volume for the install._

_If everything went well, you'll see the rEFIt boot menu on the next restart._

If you run into any problems, you can find more details on [their website][1].

## 2. Resize Partitions

This step is pretty straight-forward. Just open Disk Utility in OSX, and resize your existing OSX partition, so that there's some free space for Ubuntu. You'll want to leave the empty space as "free space" (it will get formatted during the Ubuntu installation). There are plenty of guides, if you get stuck on this step, including the [Ubuntu wiki][2].

## 3. Create USB Installer

The ISOs on the main Ubuntu download page don't work, so you'll need to get the [Ubuntu ISO for Macs][3], which is listed along with other less widely used images in their [CD images directory][4]. Once you've downloaded the Mac Ubuntu ISO, you'll need to follow some special steps to make it bootable on a Mac (the Startup Disk Creator on Ubuntu won't work). Follow the directions for the "Manual Approach" on [this wiki page][5].

## 4. Install Ubuntu

It seems that something in the Macbook power management causes a kernel panic, so you'll need to run the installer with the "noapic" option (press space at the splash screen, then F6). Note: you may need to reboot several times, as the installer may kernel panic before you have the option to set "noapic". Also, note that the wifi won't work (we'll fix this in the next step), so don't try to install updates during the installation process.

Once the installation finishes, you'll need to boot up with the noapic option (press 'e' in GRUB and add it to the kernel parameters, right next to "splash" and "quiet"), and then add it permanently once you've booted up. You can find detailed directions for both of these steps in the [Ubuntu guide for Kernel Boot Parameters][6].

## 5. Install Wifi Drivers

You'll need to be a bit creative here. Apple removed the ethernet port, so you'll need a USB wifi card, or some other method of installing the drivers (I tethered my Android phone using EasyTether). Once you have a working Internet connection, just follow these directions to install the driver:

```bash
sudo add-apt-repository ppa:mpodroid/mactel

sudo apt-get update

sudo apt-get install b43-fwcutter firmware-b43-installer

sudo apt-get install linux-backports-modules-cw-3.3-precise-generic
```

_Edit `/etc/modprobe.d/blacklist.conf` and add the line:_

`blacklist ndiswrapper`

_Create or edit the file `/etc/pm/config.d/modules` and make sure the wireless modules (b43 and bcma) are blacklisted:_

`SUSPEND_MODULES="b43 bcma"`

_Reboot and the wireless should work._

These directions are adapted from the [Ubuntu directions for installing 11.10 on a Macbook Pro][7].

## 6. Not Yet Working

Here's a list of the things that aren't working for me

* Brightness control for screen (apple-gmux)
* Volume control and other special keys on keyboard (pommed)
* Touchpad (synaptics driver)
* Internal screen resolution (maximum detected is 1024x768) & external monitor. I installed the [new nvidia driver][8] (>= 295.59) and [Bumblebee][9], which atleast means that the Additional Drivers window in Ubuntu detects the proprietary drivers, but it says they're "activated but not currently in use". Let me know in the comments if you have any luck fixing this!

 [1]: http://refit.sourceforge.net/doc/c1s1_install.html
 [2]: https://help.ubuntu.com/community/MactelSupportTeam/AppleIntelInstallation#Quick_Steps
 [3]: http://cdimage.ubuntu.com/releases/12.04/release/ubuntu-12.04-desktop-amd64+mac.iso
 [4]: http://cdimage.ubuntu.com/releases/12.04/release/
 [5]: https://help.ubuntu.com/community/How%20to%20install%20Ubuntu%20on%20MacBook%20using%20USB%20Stick#Manual_Approach
 [6]: https://wiki.ubuntu.com/Kernel/KernelBootParameters
 [7]: https://help.ubuntu.com/community/MacBookPro8-2/Oneiric#Wireless
 [8]: http://www.techlw.com/2012/06/install-nvidia-driver-in-ubuntu.html
 [9]: https://wiki.ubuntu.com/Bumblebee
