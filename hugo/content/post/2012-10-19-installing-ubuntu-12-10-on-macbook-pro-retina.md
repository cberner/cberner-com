---
title: Installing Ubuntu 12.10 on Macbook Pro Retina (10,1)
author: Christopher Berner
type: post
date: 2012-10-19T07:42:41+00:00
url: /2012/10/19/installing-ubuntu-12-10-on-macbook-pro-retina/
categories:
  - Ubuntu

---
Well, 12.10 (quantal quetzal) is out and runs a lot better on a Macbook Pro retina (rMBP) than 12.04. Just installed it on my retina and I think I can finally use it as my day to day laptop!

### Improved from 12.04

  1. Better APIC support in the kernel (previous you had to boot with noapic)
  2. Special keys on keyboard work (volume control...etc)
  3. Better touchpad support (two-finger scrolling works!)
  4. Got full resolution ~~and external monitor~~ (edit: ran into some issues after trying to boot between OSX and Ubuntu, that I haven't figured out yet) working! (this might have worked in 12.04, but I didn't test EFI booting with 12.04)

So, without further ado, the directions!

## 1. Preparation

Just follow steps 1 through 3 in [my last guide][1], to get rEFIt installed and prepare to install Ubuntu. Make sure you download the [12.10 ISO][2] though, for step 3.

## 2. Install Ubuntu

Kernel modesetting doesn't work, and will give you a garbled display, so make sure you disable it before starting the installer (press space at the splash screen, then F6, and turn on nomodeset). Also, note that the wifi won't work (we'll fix this in the next step), so don't try to install updates during the installation process.

## 3. Update Kernel Options

Once the installation finishes, you'll need to boot up with the nomodeset option (press 'e' in GRUB and add it to the kernel parameters, right next to "splash" and "quiet"), and then add it permanently once you've booted up:

1. In a terminal run: `sudo gedit /etc/default/grub`
2. Add "nomodeset" to `GRUB_CMDLINE_LINUX_DEFAULT` _inside_ the double-quotes after the words "quiet splash".
3. Finally, run: `sudo update-grub`

You can find detailed directions for both of these steps in the [Ubuntu guide for Kernel Boot Parameters][3].

## 4. Install Wifi Drivers

You'll need to be a bit creative here. Apple removed the ethernet port, so you'll need a USB wifi card, or some other method of installing the drivers (I tethered my Android phone using EasyTether). Once you have a working Internet connection, just follow these directions to install the driver:

1. `sudo apt-get update && sudo apt-get install b43-fwcutter`
2. Download driver from: <http://www.lwfinger.com/b43-firmware/broadcom-wl-5.100.138.tar.bz2>
3. `tar -xf broadcom-wl-5.100.138.tar.bz2`
4. `sudo b43-fwcutter -w /lib/firmware broadcom-wl-5.100.138/linux/wl_apsta.o`
5. Reboot and the wireless should work.

## 5. EFI Boot and NVIDIA Drivers

To get the 2880x1800 native resolution, and the external display ports working you'll need to convert GRUB to EFI mode. Follow these steps adapted from the [Ubuntu UEFI page][4]:

1. `sudo add-apt-repository ppa:yannubuntu/boot-repair && sudo apt-get update`
2. `sudo apt-get install -y boot-repair && boot-repair`
3. Click on "Advanced options", go to the "GRUB location" tab.
4. Make sure that "Separate /boot/efi partition" is checked, then click the "Apply" button.

Before restarting you'll need to install the proprietary NVIDIA drivers, and configure Xorg:

1. `sudo apt-get install linux-headers-$(uname -r)`
2. `sudo apt-get install nvidia-current`
3. `sudo nvidia-xconfig`

Restart, and you should now have a new option in rEFIt (or maybe a couple of them...), which will boot up Ubuntu using EFI.

## 6. Still Broken

* Brightness controls for monitor
* Wifi is sometimes flaky (tons of packet loss, until I reload the b43 module)
  
Let me know in the comments, if you get brightness controls working or find more stable wifi drivers!

 [1]: http://cberner.com/2012/07/10/installing-ubuntu-12-04-on-macbook-pro-retina/ "Installing Ubuntu 12.04 on Macbook Pro Retina (10,1)"
 [2]: http://releases.ubuntu.com/12.10/ubuntu-12.10-desktop-amd64+mac.iso
 [3]: https://wiki.ubuntu.com/Kernel/KernelBootParameters
 [4]: https://help.ubuntu.com/community/UEFI#Converting_Ubuntu_into_EFI_mode
