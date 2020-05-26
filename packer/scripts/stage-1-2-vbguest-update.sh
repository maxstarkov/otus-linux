#!/bin/bash

# Remove old devel and headers
yum remove kernel-devel kernel-headers -y
# Install new kernel devel and headers
yum --enablerepo elrepo-kernel install kernel-ml-devel kernel-ml-headers -y
# Install the needed packages
yum install gcc make perl -y
# Update vbguest
cd /tmp
curl http://download.virtualbox.org/virtualbox/6.0.20/VBoxGuestAdditions_6.0.20.iso --output VBoxGuestAdditions.iso
mount -o loop VBoxGuestAdditions.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions.iso
echo "VBGuest update done."
# Reboot VM
shutdown -r now
