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
vboxmanage modifyvm "$vmname" --cpus 2 --memory 32768 --vram 64 --graphicscontroller vmsvga --usbohci on --mouse usbtablet --clipboard-mode=bidirectional
vboxmanage createhd --filename "$vmdisk" --size 65536 --variant Standard
vboxmanage storagectl "$vmname" --name "SATA Controller" --add sata --bootable on
vboxmanage storageattach "$vmname" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vmdisk"
vboxmanage storagectl "$vmname" --name "IDE Controller" --add ide
vboxmanage storageattach "$vmname" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$media"

# Start the VM
echo "INFO: starting the virtual machine."
echo "INSTRUCTIONS: Use the GUI to:"
echo "INSTRUCTIONS:  1. Select the default boot option"  
echo "INSTRUCTIONS:  2. Click on 'Install Ubuntu'"
echo "INSTRUCTIONS:  3. Follow instructions to: choose your language; any accessability options; select your keyboard layout; use wired network connection; skip the new installer"
echo "INSTRUCTIONS:  4. When 'What do you want to do with Ubuntu' appears, ensure 'Install Ubuntu' is selected and click 'Next'."
echo "INSTRUCTIONS:  5. Select 'Interactive install'"
# TODO: add an autoinstall.yaml?
echo "INSTRUCTIONS:  6. When asked 'What apps would you like to install to start with?' select the default."
echo "INSTRUCTIONS:  7. When asked 'Install recommended proprietary software?', don't select anything."
echo "INSTRUCTIONS:  8. When asked 'How do you want to install Ubuntu?' select 'Erase disk...'"
echo "INSTRUCTIONS:  9. For 'Create your account', complete the details you would like to use."
echo "INSTRUCTIONS: 10. For 'Select your timezone' ensure that 'Europe/London' is selected."
echo "INSTRUCTIONS: 11. When asked 'Review your choices' click on 'Install'.  Then wait!"
echo "INSTRUCTIONS: 12. Once the install is complete, click 'Restart now'."
echo "INSTRUCTIONS: 13. The virtual CD containting the install media should have been ejected so it is safe to hit ENTER to the message 'Please remove the installation medium, then press ENTER'"
echo "INSTRUCTIONS: 14. After the reboot completes you will see a welcome message; click 'Next'."
echo "INSTRUCTIONS: 15. When asked 'Enable Ubuntu Pro' ensure 'Skip for now' is selected. Click 'Next'"
echo "INSTRUCTIONS: 16. When asked 'Help improve Ubuntu' select 'No, don't share system data'. Click 'Next'; then clock 'Finish'"
echo "INSTRUCTIONS: 17. Right click the background and select 'Open in Terminal'"
echo "INSTRUCTIONS: 18. In the terminal enter 'sudo apt update;sudo apt upgrade -y' and enter your login password when asked.  This will upgrade any old packages."
echo "INSTRUCTIONS: 19. Install clipboard sharing, etc., using: 'sudo apt install -y virtualbox-guest-x11;sudo VBoxClient --clipboard"
vboxmanage startvm "$vmname"



