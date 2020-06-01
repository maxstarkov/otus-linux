# Восстановление корневого раздела.

# Монитируем файловую систему на logical volume - LogVol00
mount /dev/VolGroup00/LogVol00 /mnt

# Переносим корневой раздел
xfsdump -l0 -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt

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
EOF

# Перезагрузка
reboot