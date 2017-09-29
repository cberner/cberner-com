---
title: Programming for the Orangutan SVP-1284 on Ubuntu
author: Christopher Berner
type: post
date: 2010-05-18T06:42:02+00:00
url: /2010/05/17/programming-for-the-orangutan-svp-1284-on-ubuntu/
categories:
  - Robotics

---
I just got my Orangutan SVP-1284, which uses the Atmega1284 processor.

Getting your dev environment setup on Ubuntu is pretty easy:

1) Download the prerequisites you need (http://www.pololu.com/docs/0J20/2)
  
`sudo apt-get install avr-libc gcc-avr avra binutils-avr avrdude`

2) Download the latest Pololu library from: http://www.pololu.com/docs/0J20/3

3) Extract the library, and install it. From the extracted directory run:
  
`sudo cp *.a /usr/lib/avr/lib/ && sudo cp -r pololu /usr/lib/avr/include/`

4) As of version 5.10 of AVRDUDE, the default config file will not work. Edit /etc/avrdude.conf and under the ATmega1284P section change chip\_erase\_delay to 55000, if you have the SVP324 then change the ATmega324PA section instead.

5) Test that everything is working. The green LED should be on, to indicate that the ISP is working, and the blue LED should be on to indicate that the AVR is receiving power. (The AVR will not receive power from the USB connection, so make sure that you provide power on GND and VIN.) Also if you run: `dmesg` 
You should see that three new devices have been detected on ttyACM0, ttyACM1, and ttyACM2. If your computer lists different ports you will need to edit the PORT section of the Makefile in step 6.

6) Check that you can program your microcontroller. From the Pololu library that you extracted, look in examples/atmega1284p/simple-test, then run:
  
`make && make program`

7) Note: If you decide to program in C++, make sure you set the CXX variable to 'avr-g++' in your Makefile, and set CXXFLAGS to CFLAGS
