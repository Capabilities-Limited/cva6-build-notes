![Cap Ltd Logo](./img/CapLtdLogo.png)

# Boot linux on CVA6

This guide explains how to produce a linux kernel and boot it on CVA6 on a Genesys 2 board.
It uses the [CVA6 SDK](https://github.com/openhwgroup/cva6-sdk) repository and follows the instructions given there.

## Build a linux image

To build a linux image, first clone the CVA6 SDK repository, `cd` into it and clone all submodules:

```
git clone https://github.com/openhwgroup/cva6-sdk.git
cd cva6-sdk
git submodule update --init --recursive
```
and install the following required packages:
```
sudo apt install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev
```

You can then build the SBI firmware and the Linux image with the following command:
```
make images
```

## Prepare the SD card for the Genesys 2

Once the SBI firmware and Linux image built, you have to write them to an SD card which will let CVA6 boot linux once inserted in the Genesys 2 board.
The CVA6 SDK Makefile offers the `flash-sdcard` target which uses the `SDDEVICE` environment variable to specify the device to write to.
Assuming your SD card shows as `/dev/sdb` on your system and that you need root privileges to access it, you will need to run the make command with elevated privileges.
Using `sudo` will allow access but will need to be called with the `-E` flag which will take care to preserve the calling environment (and the `SDDEVICE` variable in particular!).
Run the following command (adapting `/dev/sdb` to your needs) to write the SD card:
```
sudo -E make flash-sdcard SDDEVICE=/dev/sdb
```

## Boot Linux on CVA6 on the Genesys 2

Prepare a Genesys 2 board with a CVA6 image (as explained [here](https://github.com/Capabilities-Limited/cva6/tree/v5.1.0-patched?tab=readme-ov-file#programming-the-memory-configuration-file)).
Insert the SD card written with the SBI firmware and the Linux image in the Genesys 2 board.
Connect to the serial port, using `picocom` or `screen` for example (as suggeseted in the [CVA6 repository](https://github.com/Capabilities-Limited/cva6/tree/v5.1.0-patched?tab=readme-ov-file#preparing-the-sd-card)).
```
screen /dev/ttyUSB0 115200
```
You can also use PlatformIO serial connection directly if using a PlatformIO flow.

Finally, turn on the Genesys 2 board and should be able to sede bootloader messages followed by Linux kernel messages, and eventually reach a root prompt.
