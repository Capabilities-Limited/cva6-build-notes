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
git clone --depth 1 --branch v5.1.0 https://github.com/openhwgroup/cva6.git
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

