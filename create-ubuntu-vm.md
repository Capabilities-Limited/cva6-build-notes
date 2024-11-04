![Cap Ltd Logo](./img/CapLtdLogo.png)

# Install a VirtualBox VM containing Ubuntu 24.04 LTS Desktop

## Instructions to manually install a VM

Downloaded the latest Ubuntu 24.04 LTS iso from the Ubuntu website
[https://ubuntu.com/download/desktop](https://ubuntu.com/download/desktop) - look for file ubuntu-24.04-desktop-amd64.iso

Install virtual box, create a new VM and set the following parameters:
 - video memory: 64MiB
 - RAM:  32GiB
 - Disc: 64GiB VMDK image
 - CPUs: 4 or more
Set the optical disc in the VM to point to the downloaded iso and boot. Keep the
default options far installation, username "user", password "pass". When install
is complete, reboot without the iso.

A smaller configuration has been tested, which is sufficient to build the simulation and verification environment, but it likely to be too small for FPGA builds using Vivado:
 - video memory: 32MiB
 - RAM:  10GiB
 - Disc: 64GiB VMDK image
 - CPUs: 2 or more

Install the ISO file as the virtual CD in the VM configuration, then boot up the ISO image and following the [instructions below](#completing-the-install-on-the-virtual-machine).

## Script to build a VirtualBox VM

The following has been tested in a Ubuntu box. This is based on the larger configuration listed above.

```bash
#!/bin/bash

# Set Ubuntu version
ubuntuversion="24.04"

# Name the virtual machine
vmname="Ubuntu "$ubuntuversion

# Exit script on first error:
set -e
# Show commands executed
set -o xtrace

# Force virtual box VMs to be created locally:
export VBOX_USER_HOME=`pwd`/VirtualBoxVMs

# Location of the final VM confuguration
vmconfigdir="~/VirtualBox VMs/$vname"

# Location of the virtual disk
vmdisk=$VBOX_USER_HOME/Ubuntu$ubuntuversion.vdi

if [ -d $vmconfigdir ]; then
   echo "ERROR: there is an existing earlier installation in $vmconfigdir. Delete before rerunning this script."
   exit
fi
if [ -d $vmdisk ]; then
   echo "ERROR: there is an existing earlier installation of a VM disk in "$vmdisk". Remove files in directory "$VBOX_USER_HOME" before reruning this script."
   exit
fi
   
# Download Ubuntu desktop image from University of Kent mirror
media="ubuntu-"$ubuntuversion"-desktop-amd64.iso"
echo "INFO: about to download $media if it has not already been downloaded"
rsync --copy-links --progress  rsync://rsync.mirrorservice.org/releases.ubuntu.com/$ubuntuversion/$media .

# Configure the virtual machine
vboxmanage createvm --name "$vmname" --ostype Ubuntu_64 --register
vboxmanage modifyvm "$vmname" --cpus 4 --memory 32768 --vram 64 --graphicscontroller vmsvga --usbohci on --mouse usbtablet --clipboard-mode=bidirectional
vboxmanage createhd --filename "$vmdisk" --size 65536 --variant Standard
vboxmanage storagectl "$vmname" --name "SATA Controller" --add sata --bootable on
vboxmanage storageattach "$vmname" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vmdisk"
vboxmanage storagectl "$vmname" --name "IDE Controller" --add ide
vboxmanage storageattach "$vmname" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$media"

# Start the VM
vboxmanage startvm "$vmname"
```

## Completing the install on the virtual machine

Use the GUI to:
1. Select the default boot option  
2. Click on 'Install Ubuntu'
3. Follow instructions to: choose your language; any accessibility options; select your keyboard layout; use wired network connection; skip the new installer
4. When 'What do you want to do with Ubuntu' appears, ensure 'Install Ubuntu' is selected and click 'Next'.
5. Select 'Interactive install'
6. When asked 'What apps would you like to install to start with?' select the default.
7. When asked 'Install recommended proprietary software?', don't select anything.
8. When asked 'How do you want to install Ubuntu?' select 'Erase disk...'
9. For 'Create your account', complete the details you would like to use.
10. For 'Select your timezone' ensure that 'Europe/London' is selected.
11. When asked 'Review your choices' click on 'Install'.  Then wait!
12. Once the install is complete, click 'Restart now'.
13. The virtual CD containing the install media should have been ejected so it is safe to hit ENTER to the message 'Please remove the installation medium, then press ENTER'
14. After the reboot completes you will see a welcome message; click 'Next'.
15. When asked 'Enable Ubuntu Pro' ensure 'Skip for now' is selected. Click 'Next'
16. When asked 'Help improve Ubuntu' select 'No, don't share system data'. Click 'Next'; then clock 'Finish'
17. Right click the background and select 'Open in Terminal'
18. In the terminal enter 'sudo apt update;sudo apt upgrade -y' and enter your login password when asked.  This will upgrade any old packages.
19. Install clipboard sharing, etc., using: 'sudo apt install -y virtualbox-guest-x11;sudo VBoxClient --clipboard




