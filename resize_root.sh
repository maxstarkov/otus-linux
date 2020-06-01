# Удаляем старый logical volume
lvremove -f /dev/VolGroup00/LogVol00

# Создаем новый logical volume размером 8ГБ
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00

# Создаем файловую систему
mkfs.xfs /dev/VolGroup00/LogVol00