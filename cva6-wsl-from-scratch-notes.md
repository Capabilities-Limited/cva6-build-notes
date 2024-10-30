![Cap Ltd Logo](./img/CapLtdLogo.png)

# DRAFT NOTES: Setup a WSL to host a CVA6 simulation environment

## History

This is a draft note based on the [cva6-vm-from-scratch-notes.md](cva6-vm-from-scratch-notes.md) instructions modified for Windows Subsystem for Linux rather than using a virtual machine.  Further testing is required.

To be tested:
* Currently we don't know if Vivado for Linux can be successfully installed under WSL.  This will be needed to use the automated FPGA build system.

## Install Windows Subsystem for Linux (WSL)

Install Ubuntu 24.04 LTS in WSL.  Open PowerShell and enter:
```
wsl --install -d Ubuntu-24.04
```

Reboot when done.  WSL should open when you login after the reboot.
You will need to complete the install by setting up a user account as
directed.


## Obtaining a copy of the CVA6 repository

In the Ubuntu VM, start by updating all packages:
`sudo apt update && sudo apt upgrade -y`


NOTE REQUIRED FOR WSL: Then install `git`:
```sh
sudo apt install -y git
```

You may also like to install an editor like vim: `sudo apt install -y vim`

Clone the CVA6 repository (and update submodules) at the `v5.1.0` tag
(no history needed):
```sh
cd ~/
git clone --depth 1 --branch v5.1.0-patched https://github.com/Capabilities-Limited/cva6.git
cd cva6
git submodule update --init --recursive
```

## Following the CVA6 instructions

As per the CVA6 README, first set your `NUM_JOBS` environment variable. Set this to a value just less than the number of virtual cores in your VM:
```sh
export NUM_JOBS=3
```

Then we look at the gcc toolchain...

### Following the gcc-toolchain-builder README

REQUIRED FOR WSL:
```sh
sudo add-apt-repository universe multiverse
```

Install the prerequisites:
```sh
sudo apt install -y autoconf automake autotools-dev curl git libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool bc zlib1g-dev
```

The next step is to "fetch and build the upstream gcc toolchain". Here, we have
the first mention of the `RISCV` environment variable. It is assumed set already
in the gcc-toolchain-builder README. Let us create a directory to host the tools
and record its path in the `RISCV` environment variable.
```sh
mkdir ~/riscv-tools
export RISCV=~/riscv-tools
```

Resume with the gcc-toolchain-builder README, fetch and install the toolchain:
```sh
cd ~/cva6/util/gcc-toolchain-builder
export INSTALL_DIR=$RISCV
sh get-toolchain.sh
sh build-toolchain.sh $INSTALL_DIR
```

### Back to the main CVA6 README

We proceed, making sure our `RISCV` environment variable is correctly set, and
back from the cva6 root folder.
```sh
export RISCV=~/riscv-tools
export CVA6_REPO_DIR=~/cva6
cd ~/cva6
```

We install  `help2man` and `device-tree-compiler`:
```sh
sudo apt install -y help2man device-tree-compiler
```

We install the riscv-dv requirements. This first requires python packages which
are now (recent python3 from Ubuntu 24.04) managed using a python virtual
environment. Create a new python virtual environment and run pip to install the
python packages from the requirement.txt file:
```sh
sudo apt install -y python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r verif/sim/dv/requirements.txt
```

Finally, to run the smoke tests:
```sh
export DV_SIMULATORS=veri-testharness,spike
bash verif/regress/smoke-tests.sh
```
Optional: you can deactivate the python virtual environment once done:
```sh
deactivate
```

To view the test log, look in the dated directory out_ here:
```
less ~/cva6/verif/sim/out_*/iss_regr.log
```

Note that the log should show the comparison between tests running the CVA6 core in Verilator against the Spike ISA simulator.

To run the full test suite, execute 'bash verif/regress/dv-riscv-arch-test.sh'

# FPGA build of CVA6 from WSL2 using Windows Vivado

## Motivation

Provide build support for Windows users.  While we could probably
install Vivado under WSL2 (Windows Subsystem for Linux 2), the Windows
version of Vivado includes the required device drivers for JTAG
access, etc.

## Notes WSL2/Windows Interoperability

* Running programs:
  * Some Windows applications can simply be run directly from WSL2
  * Vivado is normally started via a bat script (vivado.bat) on Windows that can be called via cmd.exe

* Interoperability of files and environment variables between WSL2 and Windows:
  [https://learn.microsoft.com/en-us/windows/wsl/filesystems](https://learn.microsoft.com/en-us/windows/wsl/filesystems)
  * The Windows home filespace is accessible from WSL as /mnt/c/Users/username
  * The WSL2 filespace is accessible from Windows as \\wsl$ in filer, or from PowerShell as \\wsl.localhost\Ubuntu-24.04\home\username
  * When calling commands from WSL2, the shared environment variables are specified by the colon separated list in environment variable WSLENV. Note that this list can also specify path modifiers, etc. - see the above guide

## Dependencies

Microsoft Visual C++ Redistributed Version appears to be required.  Install the x64 version from:
https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170


## Vivado install on Windows

All of the notes in this section are based on running from Windows, not WSL2.

From:
https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html

Download the "Vivado HLx 2020.1: All OS installer Single-File Download"
which should download:
  Xilinx_Unified_2020.1_0602_1208.tar.gz

In file explorer, right click on the above tar file and "Extract All..." into the default directory.

In the extracted directory, double click on xsetup.exe to start the installation.
* Agreed to Java accessing the network
* Agreed to the Xilinx end user agreement, the WebTalk Term and Conditions and the Third Party Software End User License Agreement, otherwise the install will not proceed.
* Under "Select Product to Install" first tick "Vivado".
  * Install the default "Vivado HL System Edition"
  * I went with the default devices, etc., but could be more selective.
  * Left the default location for tools.
  * Finally, setup your licensing to suit your local support.


## Installing the Genesys 2 Board Support Package

* Based on the Digilent guide here: [https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-sdk](https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-sdk)

* In a WSL2 shell:
```
cd /mnt/c/Users/$LOGNAME
git clone https://github.com/Digilent/vivado-boards.git
# check that we have access to the Vivado boards directory:
ls /mnt/c/Xilinx/Vivado/2020.1/data/boards/board_files/
# copy over the Digilent board support files
cp -a vivado-boards/new/board_files/* /mnt/c/Xilinx/Vivado/2020.1/data
/boards/board_files/
```

* Note that if the Digilent files vanish from the web, Xilinx have a copy on their GitHub:
  [https://github.com/Xilinx/XilinxBoardStore/tree/2020.1/boards/Digilent/genesys2/H](https://github.com/Xilinx/XilinxBoardStore/tree/2020.1/boards/Digilent/genesys2/H)


# Running Windows Vivado from WSL2

* Vivado on Windows is normally started using the script vivado.bat
* One approach to initiate vivado.bat with the correct parameters is via a script on the WSL2 side that can be installed in ~/bin/vivado :
```
#!/bin/sh
# environment variables to export from WSL2 to Windows
export WSLENV=XILINX_PART:XILINX_BOARD:BOARD
# now start vivado and pass any command-line options
cmd.exe /s /mnt/c/Xilinx/Vivado/2020.1/bin/vivado.bat $*
```
You also need to make sure that script is executable to call it from the command line:
```
chmod +x ~/bin/vivado
```

* Add ~/bin to your PATH so that running 'vivado' will call the above script, vis:
```
export PATH=~/bin:$PATH
```
  * Note that the default ~/.profile will add this path every time a new shell is started


## FPGA build from scratch

* Move the cva6 repo from the WSL2 space to Windows so that it is accessible on the Windows side using traditional Windows path names, which appears to be required by the Vivado startup scripts.  Add a symbolic link so the cva6 directory appears in the same path on WSL2:
```
mv cva6 /mnt/c/Users/$LOGNAME/
ln -s /mnt/c/Users/$LOGNAME/cva6 ~/cva6
```

* Reuse RISC-V tools and the CVA6 repo downloaded for simulation.  Note that we want to use the Windows path to the CVA6_REPO_DIR:
```
export RISCV=~/riscv-tools
export CVA6_REPO_DIR=/mnt/c/Users/$LOGNAME/cva6
```

* Start in the CVA6 directory on the Windows path:
```
cd /mnt/c/Users/$LOGNAME/cva6/
```

* Make sure the fpga build space is clean
```
make -C corev_apu/fpga clean
```

* Finally, we can perform the FPGA build using our modified Makefile that adjusts the paths in generated tcl files to work with Windows:
```
make -f Makefile_capltd fpga
```
