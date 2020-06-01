mdadm --zero-superblock /dev/sd{b,c}
mdadm --create /dev/md0 --metadata=1.0 --level=1 --raid-device=2 /dev/sd{b,c}
