---
title: Installing Ubuntu 16.04 on Macbook Pro Retina (10,1)
author: Christopher Berner
type: post
date: 2016-06-08T18:11:47+00:00
url: /2016/06/08/installing-ubuntu-16-04-macbook-pro-retina-101/
categories:
  - Ubuntu

---
I did a fresh install of 16.04 on my Macbook Pro (rMBP). It seems quite stable so far, and brings a number of improvements over 14.04.

### Improved from 14.04

1. _No more special ISO (works with the default amd64 image)_
2. _EFI is setup by default now_
3. _Nvidia driver is automatically configured_

Now for the directions!

## 1. Resize Partitions

This step is pretty straight-forward. Just open Disk Utility in OSX, and resize your existing OSX partition, so that there's some free space for Ubuntu. You'll want to leave the empty space as "free space" (it will get formatted during the Ubuntu installation). There are plenty of guides, if you get stuck on this step, including the [Ubuntu wiki][1].

## 2. Install rEFInd

1. _Download [rEFInd 0.10.3](http://sourceforge.net/projects/refind/files/0.10.3/refind-bin-0.10.3.zip/download)_
2. _Unzip the package._
3. _Run the refind-install script._

If everything went well, you'll see the rEFInd boot menu on the next restart. If you run into any problems, you can find more details on [their website][2].

## 3. Create USB Installer

Download the Ubuntu 16.04 ISO. Once you've downloaded the ISO, you'll need to follow some special steps to make it bootable on a Mac (the Startup Disk Creator on Ubuntu won't work). Follow the directions for the "Manual Approach" on [this wiki page][3].

## 4. Install Ubuntu

Note that the wifi won't work (we'll fix this in the next step), so don't try to install updates during the installation process, unless you have a separate usb wifi dongle or ethernet. When installing select the "Try Ubuntu" option and then run the installer icon on the desktop. Selecting "Install" from the textually menu doesn't seem to work. Also, at the end of the installer, after the dialog asking you to restart, you'll probably get a black screen. Just press spacebar and it should reboot.

## 5. Install Wifi Drivers

Wifi doesn't work out of the box, so from another computer (or your OSX install) [download the driver][4] and its dependencies (dkms, libc6-dev, linux-libc-dev), then copy them all to a flash drive and boot back into Ubuntu. Install each with:

```bash
sudo dpkg -i "the package file you downloaded"
```

Alternatively, if you have a usb wifi card, you can use that and install the driver with this command:

```bash
sudo apt-get update && sudo apt-get install bcmwl-kernel-source
```

## 6. NVIDIA Drivers

Now you'll need to install the proprietary NVIDIA drivers. Open "Additional Drivers" and select the latest proprietary driver.

## 7. Other Configuration (optional)

If you're like me and want the F1-F12 keys to behave as function keys, and not special keys then just follow these steps from the [AppleKeyboard guide](https://help.ubuntu.com/community/AppleKeyboard)

```bash
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all
sudo reboot
```

Also, if you want to allow the processor to run at full speed, you'll want to disable power clamping:

```bash
echo "blacklist intel_powerclamp" | sudo tee -a /etc/modprobe.d/disable-powerclamp.conf
```

## 8. Still Broken

* Only the native resolution (2880x1800) is available, which means the text is rather small

 [1]: https://help.ubuntu.com/community/MactelSupportTeam/AppleIntelInstallation#Quick_Steps
 [2]: http://www.rodsbooks.com/refind/
 [3]: https://help.ubuntu.com/community/How%20to%20install%20Ubuntu%20on%20MacBook%20using%20USB%20Stick#Manual_Approach
 [4]: http://packages.ubuntu.com/raring/bcmwl-kernel-source
