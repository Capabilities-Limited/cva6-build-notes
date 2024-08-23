#!/usr/bin/bash
# exit script on first error:
set -e
# show commands executed
set -o xtrace
sudo apt install -y git
cd ~/
git clone --depth 1 --branch v5.1.0 https://github.com/openhwgroup/cva6.git
cd cva6
git submodule update --init --recursive
export NUM_JOBS=3
sudo apt install -y autoconf automake autotools-dev curl git libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool bc zlib1g-dev
mkdir ~/riscv-tools
export RISCV=~/riscv-tools
cd ~/cva6/util/gcc-toolchain-builder
export INSTALL_DIR=$RISCV
sh get-toolchain.sh
sh build-toolchain.sh $INSTALL_DIR
export RISCV=~/riscv-tools
export CVA6_REPO_DIR=~/cva6
cd ~/cva6
sudo apt install -y help2man device-tree-compiler
sudo apt install -y python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r verif/sim/dv/requirements.txt
export DV_SIMULATORS=veri-testharness,spike
bash verif/regress/smoke-tests.sh
sudo apt install -y git
cd ~/
git clone --depth 1 --branch v5.1.0 https://github.com/openhwgroup/cva6.git
cd cva6
git submodule update --init --recursive
export NUM_JOBS=5
sudo apt install -y autoconf automake autotools-dev curl git libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool bc zlib1g-dev
mkdir ~/riscv-tools
export RISCV=~/riscv-tools
cd ~/cva6/util/gcc-toolchain-builder
export INSTALL_DIR=$RISCV
sh get-toolchain.sh
sh build-toolchain.sh $INSTALL_DIR
export RISCV=~/riscv-tools
export CVA6_REPO_DIR=~/cva6
cd ~/cva6
sudo apt install -y help2man device-tree-compiler
sudo apt install -y python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r verif/sim/dv/requirements.txt
export DV_SIMULATORS=veri-testharness,spike
bash verif/regress/smoke-tests.sh
sudo apt install -y git
cd ~/
git clone --depth 1 --branch v5.1.0 https://github.com/openhwgroup/cva6.git
cd cva6
git submodule update --init --recursive
export NUM_JOBS=5
sudo apt install -y autoconf automake autotools-dev curl git libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool bc zlib1g-dev
mkdir ~/riscv-tools
export RISCV=~/riscv-tools
cd ~/cva6/util/gcc-toolchain-builder
export INSTALL_DIR=$RISCV
sh get-toolchain.sh
sh build-toolchain.sh $INSTALL_DIR
export RISCV=~/riscv-tools
export CVA6_REPO_DIR=~/cva6
cd ~/cva6
sudo apt install -y help2man device-tree-compiler
sudo apt install -y python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r verif/sim/dv/requirements.txt
export DV_SIMULATORS=veri-testharness,spike
bash verif/regress/smoke-tests.sh
sudo apt install -y git
cd ~/
git clone --depth 1 --branch v5.1.0 https://github.com/openhwgroup/cva6.git
cd cva6
git submodule update --init --recursive
export NUM_JOBS=5
sudo apt install -y autoconf automake autotools-dev curl git libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool bc zlib1g-dev
mkdir ~/riscv-tools
export RISCV=~/riscv-tools
cd ~/cva6/util/gcc-toolchain-builder
export INSTALL_DIR=$RISCV
sh get-toolchain.sh
sh build-toolchain.sh $INSTALL_DIR
export RISCV=~/riscv-tools
export CVA6_REPO_DIR=~/cva6
cd ~/cva6
sudo apt install -y help2man device-tree-compiler
sudo apt install -y python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip3 install -r verif/sim/dv/requirements.txt
export DV_SIMULATORS=veri-testharness,spike
bash verif/regress/smoke-tests.sh
deactivate