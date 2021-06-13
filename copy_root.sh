# Установка необходимых пакетов.
yum install -y mdadm smartmontools hdparm gdisk xfsdump

# Подготовка временного корневого раздела.

# Создаем physical volume
pvcreate /dev/sdb

# Создаем volume group - vg_root
vgcreate vg_root /dev/sdb

# Создаем logical volume - lv_root
lvcreate -n lv_root -l +100%FREE /dev/vg_root

# Создаем и монитируем файловую систему на logical volume - lv_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt

# Переносим корневой раздел
xfsdump -l0 -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt

# Перемонтируем системную информацию
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
mount --bind /run /mnt/run
mount --bind /boot /mnt/boot

# Меняем корень на новый
chroot /mnt /bin/bash << "EOF"
# Создаем новую конфигурацию загрузчика grub
grub2-mkconfig -o /boot/grub2/grub.cfg

# Собираем initramfs
dracut --force /boot/initramfs-$(uname -r).img $(uname -r) -M

# Исправим указание на нужную logical volume
sed -i "s|rd.lvm.lv=VolGroup00/LogVol00|rd.lvm.lv=vg_root/lv_root|g" /boot/grub2/grub.cfg
EOF

# Перезагрузка
reboot