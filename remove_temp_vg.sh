# Удаляем временный logical volume, который использовалась для переноса корня
lvremove -f /dev/vg_root/lv_root

# Удаляем временную volume group
vgremove /dev/vg_root

# Удаляем временный physical volume
pvremove /dev/sdb