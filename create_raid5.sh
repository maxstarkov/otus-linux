mdadm --create /dev/md0 --level=5 --raid-device=5 /dev/sd{b,c,d,e,f}
parted /dev/md0 mklabel gpt
parted -a optimal /dev/md0 -s mkpart primary 0 20% mkpart primary 20% 40% mkpart primary 40% 60% mkpart primary 60% 80% mkpart primary 80% 100%
