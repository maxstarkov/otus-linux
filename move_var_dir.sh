# Перенос var на lvm-зеркало

# Создаем physical volume
pvcreate /dev/sdc /dev/sdd

# Создаем volume group - vg_var
vgcreate vg_var /dev/sdc /dev/sdd

# Создаем logical volume - lv_var с одной копией
lvcreate -n lv_var -L 950M -m1 vg_var

# Создем и монтируем на lv_var файловую систему, копируем каталог var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/
rm -rf /var/*

# Перемонтируем lv_var в /var
umount /mnt
mount /dev/vg_var/lv_var /var

# Добавим запись в fstab для автоматического монтирования /var
echo "$(blkid | grep var: | awk '{print $2}') /var ext4 defaults 0 0" >> /etc/fstab

# Перезагрузка
reboot