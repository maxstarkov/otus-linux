#!/bin/bash

# Remove old devel and headers
yum remove kernel-devel kernel-headers -y
# Install new kernel devel and headers
yum --enablerepo elrepo-kernel install kernel-ml-devel kernel-ml-headers -y
# Install the needed packages
yum install centos-release-scl -y
yum install devtoolset-8 -y
# Update vbguest
cd /tmp
curl http://download.virtualbox.org/virtualbox/6.1.22/VBoxGuestAdditions_6.1.22.iso --output VBoxGuestAdditions.iso
mount -o loop VBoxGuestAdditions.iso /mnt
scl enable devtoolset-8 "sh /mnt/VBoxLinuxAdditions.run"
umount /mnt
rm VBoxGuestAdditions.iso
echo "VBGuest update done."
# Reboot VM
shutdown -r now
