---
title: Installing Ubuntu 13.04 on Macbook Pro Retina (10,1)
author: Christopher Berner
type: post
date: 2013-03-02T07:43:29+00:00
url: /2013/03/01/installing-ubuntu-13-04-on-macbook-pro-retina/
categories:
  - Ubuntu

---
I've been using 13.04 (raring ringtail) daily build on my macbook pro (rMBP) for a couple days now, and things have been working great so far. Definitely a major improvement over 12.10, and for a daily build it's been pretty stable too.

### Improved from 12.10

1. Better modesetting support in the kernel (no more need for nomodeset option)
2. Proprietary Nvidia drivers finally work right
3. New wifi drivers, that actually work!

Now for the directions!

## 1. Preparation

Just follow steps 1 through 3 in [my first guide][1], to get rEFIt installed and prepare to install Ubuntu. Make sure you download the [raring ringtail daily ISO][2] though, for step 3.

## 2. Install Ubuntu

Note that the wifi won't work (we'll fix this in the next step), so don't try to install updates during the installation process, unless you have a separate usb wifi dongle or ethernet. Also, at the end of the installer, after the dialog asking you to restart, you'll probably get a black screen. Just press spacebar and it should reboot.

## 3. Install Wifi Drivers

Wifi doesn't work out of the box, so from another computer (or your OSX install) [download the driver][3] and its dependencies (dkms, libc6-dev, linux-libc-dev), then copy them all to a flash drive and boot back into Ubuntu. Install each with:

```bash
sudo dpkg -i "the package file you downloaded"
```

Alternatively, if you have a usb wifi card, you can use that and install the driver with this command:

```bash
sudo apt-get update && sudo apt-get install bcmwl-kernel-source
```

## 4. EFI Boot

To get the 2880x1800 native resolution, and the external display ports working you'll need to convert GRUB to EFI mode. Follow these steps adapted from the [Ubuntu UEFI page][4]:

  1. `sudo add-apt-repository ppa:yannubuntu/boot-repair`
  2. `sudo apt-get update`
  3. `sudo apt-get install -y boot-repair && boot-repair`
  4. Click on "Advanced options", go to the "GRUB location" tab.
  5. Make sure that "Separate /boot/efi partition" is checked, then click the "Apply" button, and follow the directions (you'll be asked to remove and reinstall GRUB)
  6. Reboot. You'll probably have several new options in rEFIt, select any of them to boot up
  7. (optional) if you want to remove some of the extra rEFIt options, just delete the directories you don't want from /boot/efi/EFI (be VERY CAREFUL here, and don't delete the APPLE directory)

Note: After changing to EFI, you may get a blank screen for several seconds during boot-up.

## 5. NVIDIA Drivers

Now you'll need to install the proprietary NVIDIA drivers, and configure Xorg:

  1. `sudo apt-get install linux-headers-$(uname -r)`
  2. `sudo apt-get install nvidia-current`
  3. `sudo nvidia-xconfig`
  4. edit /etc/X11/xorg.conf and add to the Device section: `Option "UseDPLib" "off"`
  5. edit /etc/default/grub and add `i915.lvds_channel_mode=2 i915.modeset=0 i915.lvds_use_ssc=0` to `GRUB_CMDLINE_LINUX_DEFAULT` _inside_ the double-quotes between the words "quiet splash". Then run: `sudo update-grub`
  6. Reboot and you should see the nvidia logo during boot
  7. (optional) If you don't see the nvidia logo or get a blank screen, try installing [gfxCardStatus][5] (version 2.2.1, not 2.3), and forcing the discrete graphics card from the dropdown menu of their toolbar icon. You may also need to run `sudo dpkg-reconfigure nvidia-current` after rebooting.

## 6. Other Configuration (optional)

If you're like me and want the F1-F12 keys to behave as function keys, and not special keys then just follow these steps from the [AppleKeyboard guide](https://help.ubuntu.com/community/AppleKeyboard)

```bash
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all
sudo reboot
```

## 7.Still Broken

* Brightness controls still aren't working
* Only the native resolution (2880x1800) is available, which means the text is rather small

 [1]: http://cberner.com/2012/07/10/installing-ubuntu-12-04-on-macbook-pro-retina/ "Installing Ubuntu 12.04 on Macbook Pro Retina (10,1)"
 [2]: http://cdimage.ubuntu.com/daily-live/current/raring-desktop-amd64+mac.iso
 [3]: http://packages.ubuntu.com/raring/bcmwl-kernel-source
 [4]: https://help.ubuntu.com/community/UEFI#Converting_Ubuntu_into_EFI_mode
 [5]: http://mac.majorgeeks.com/files/details/gfxcardstatus.html
