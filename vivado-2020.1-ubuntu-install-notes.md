# Setup Vivado for CVA6 bitstream builds on Ubuntu

## Download Vivado 2020.1

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

## Install Vivado 2020.1

### Prepare for the installer to run

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

---

### Option 1 - command-line based instalation
First, create an installer configuration file. Run
```
~/Downloads/Xilinx_Unified_2020.1_0602_1208/xsetup -b ConfigGen
```
selecting first `2` for `Vivado` then `3` for `Vivado HL System Edition`.
You can edit the resulting file generated under `~/.Xilinx/install_config.txt` if necessary.

Alternatively, you can manually create this file as follows:
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
~/Downloads/Xilinx_Unified_2020.1_0602_1208/xsetup --a XilinxEULA,3rdPartyEULA,WebTalkTerms -b Install -c ~/.Xilinx/install_config.txt
```

---

### Option 2 - graphical installer
Run `~/Downloads/Xilinx_Unified_2020.1_0602_1208/xsetup`. You should see the graphical installer
start. When it starts,

 - if prompted to get a newer version of the tools, don't (continue)
 - click next in the first screen
 - tick agree and click next on the next screen
 - tick Vivado and click next the next screen
 - tick Vivado HL System Edition or Vivado HL Design Edition and click next on the next screen
 - tick the desired components (at least `Devices > Production Devices > 7 Series > Kintex-7`)
   and click next on the next screen
 - select your installation path (later referred to as `<your install path>`) and click next on the next screen
 - _make sure you have enough disk space_ and click install

---

Once the installation is complete, make sure that the `vivado` binary is accessible in your `PATH`(`export PATH=<your install path>/Vivado/2020.1/bin/:$PATH`).

If you had to edit your Ubuntu version earlier, you can now restore your original `/etc/os-release`.

## Setup the Digilent Vivado board files

For the CVA6 Vivado project to build, we need the Digilent Vivado board files
to be installed. They are available in the following repository:
https://github.com/Digilent/vivado-boards.

### option 1: clone the repo and update your Xilinx user configuration
You can clone the Digilent Vivado boards repository and tell Vivado where to look for board files. Change to the directory you want your clone to live in and run
```
git clone https://github.com/Digilent/vivado-boards
```
You can then create an edited copy of the `vivado-boards/utility/Vivado_init.tcl` file into your `$HOME/.Xilinx/Vivado/` user configuration folder and point it at your clone by running
```
sed "s|<extracted path>|$PWD|" vivado-boards/utility/Vivado_init.tcl > $HOME/.Xilinx/Vivado/Vivado_init.tcl
```
(adjust `$PWD` and the various paths if running from a different location).

---

### option 2: download an archive and copy the board files in the Vivado install folder
You can download the board file archive and manually copy the board files into the Vivado install folder:
```
wget https://github.com/Digilent/vivado-boards/archive/master.zip
unzip master.zip
cp -r vivado-boards-master/new/board_files/* <your install path>/Vivado/2020.1/data/boards/board_files/
```

Once the boards files setup, you should have a working installation of Vivado 2020.1.
