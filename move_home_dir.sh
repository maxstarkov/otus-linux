# Перенос home на отдельный logical volume

# Создаем logical volume - LogVol_Home
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00

# Создем и монтируем на LogVol_Home файловую систему, копируем каталог home
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*

# Перемонтируем LogVol_Home в /home
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/

# Добавим запись в fstab для автоматического монтирования /var
echo "$(blkid | grep Home: | awk '{print $2}') /home xfs defaults 0 0" >> /etc/fstab

# Перезагрузка
reboot