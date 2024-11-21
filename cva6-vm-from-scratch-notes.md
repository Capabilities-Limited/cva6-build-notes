![Cap Ltd Logo](./img/CapLtdLogo.png)

# Setup a VM from scratch for CVA6 simulation environment

## Installing the VM

To install the base virtual machine with Ubuntu, following the [Create Ubuntu VM](./create-ubuntu-vm.md)


## Obtaining a copy of the CVA6 repository

In the Ubuntu VM, start by updating all packages:
`sudo apt update && sudo apt upgrade -y`

Then install `git`:
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

## Install Vivado and build a bitfile

Here we describe how to install Vivado 2020.1 (these instructions as well as some more GUI facing ones are available in the [vivado install notes](https://github.com/Capabilities-Limited/cva6-build-notes/blob/main/vivado-2020.1-ubuntu-install-notes.md#setup-vivado-for-cva6-bitstream-builds-on-ubuntu).

### Download Vivado 2020.1

From the Xilinx website, https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html
you can find the relevant Vivado installer under
`Vivado Archive > 2020 > 2020.1 > Vivado Design Suite - HLx Editions - 2020.1  Full Product Installation`
, with the following download link:
https://www.xilinx.com/member/forms/download/xef.html?filename=Xilinx_Unified_2020.1_0602_1208.tar.gz.
At the time of writing, obtaining the file requires a user account to be created
on the Xilinx website. Proceed with the download after having authenticated.

Assuming the `Xilinx_Unified_2020.1_0602_1208.tar.gz` file is downloaded under the `~/Downloads/` folder, extract it as follows:
```
cd ~/Downloads/
tar -xzf Xilinx_Unified_2020.1_0602_1208.tar.gz
```
The installer itself is found under `~/Downloads/Xilinx_Unified_2020.1_0602_1208/xsetup`.

### Install Vivado 2020.1

The Vivado installer checks which Ubuntu version you are currently running. It
does not support Ubuntu versions more recent than 18.04.4 LTS. This particular
installer look for version information in `/etc/os-release` (possibly `/etc/os-version`).
You can temporarily edit your `etc/os-release` to report `18.04.4` as your
Ubuntu version for the purpose of installing Vivado, and restore it once the installation
is complete. To do so, you will need root privileges (either log in as root or
don't forget to prefix the following commands by `sudo`). First, back up your `/etc/os-release`:
```
sudo cp /etc/os-release /etc/os-release.backup
```
Update the `VERSION` in the file as follows:
```
sudo sed -i 's/VERSION=.*/VERSION="18.04.4 LTS (Bionic Beaver)"/' /etc/os-release
```
Do not forget to restore the  original `/etc/os-release` once the installation is over.

Additionally, the installer looks for a specific version of `libtinfo` which can be installed as follows:
```
sudo apt update
sudo apt install libtinfo-dev
sudo ln -s /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.5
```

Prior to runing the installer, also set the `XILINXD_LICENSE_FILE` variable to point to your Vivado license:
```
export XILINXD_LICENSE_FILE=<your license server>
```

Create an installer configuration file as follows:
```
cat > ~/.Xilinx/install_config.txt << EOF
Edition=Vivado HL System Edition
Product=Vivado
Destination=/tools/Xilinx
Modules=Kintex-7:1
EOF
```

You can then run the installer as follows (`sudo` necessary for an installation under `/tools/Xilinx`):
```
sudo ~/Downloads/Xilinx_Unified_2020.1_0602_1208/xsetup --a XilinxEULA,3rdPartyEULA,WebTalkTerms -b Install -c ~/.Xilinx/install_config.txt
```

Once the installation is complete, make sure that the `vivado` binary is accessible in your `PATH`(`export PATH=/tools/Xilinx/Vivado/2020.1/bin/:$PATH`).

If you had to edit your Ubuntu version earlier, you can now restore your original `/etc/os-release`.

### Setup the Digilent Vivado board files

For the CVA6 Vivado project to build, we need the Digilent Vivado board files
to be installed. They are available in the following repository:
https://github.com/Digilent/vivado-boards.

You can download the board file archive and manually copy the board files into the Vivado install folder (you may need `sudo` for the `cp` command based on your Vivado install path):
```
wget https://github.com/Digilent/vivado-boards/archive/master.zip
unzip master.zip
sudo cp -r vivado-boards-master/new/board_files/* /tools/Xilinx/Vivado/2020.1/data/boards/board_files/
```

### Build a CVA6 bitfile
Once the boards files setup, you should have a working installation of Vivado 2020.1. You can build the CVA6 `fpga` target:
```
cd ~/cva6
make fpga
```
