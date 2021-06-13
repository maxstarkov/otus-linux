## Решение задания

Для просмотра решения задания нужно выполнить команду:

```
vagrant up otuslinux
```

Будет создана ВМ с пятью дополнительными дисками.
После создания ВМ выполнится [provision скрипт](./create_raid5.sh), который создаст raid5 из пяти дисков и создаст на нем пять одинаковых GPT партиций:

```
mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sun Jun 13 08:02:28 2021
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jun 13 08:02:33 2021
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : centos-7-raid:0  (local to host centos-7-raid)
              UUID : fb6910d0:cb70f297:1c3bbd5d:0e37adaa
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
```

На этом raid массиве можно проводить эксперименты.

### Решение задания с повышенной сложностью

Перед выполнением задания нужно запустить ВМ командой:

```
vagrant up otuslinux-migrate-to-raid
```

Будет создана ВМ с двумя дополнительными дисками.
После создания ВМ выполнится [provision скрипт](./create_raid1.sh), который создаст raid1 из двух дисков.

После сборки raid1 создаем раздел и ФС:

```
parted /dev/md0 mklabel msdos
parted -a optimal /dev/md0 mkpart primary 0% 100%
mkfs.xfs /dev/md0 -f
```

Примонтируем ФС:

```
mount /dev/md0 /mnt/
```

С помощью утилит xfsdump и xfsrestore перенесем корневой раздел на raid1 массив:

```
xfsdump -l0 -J - / | xfsrestore -J - /mnt
```

Определим UUID старого раздела:

```
blkid | grep sda
/dev/sda1: UUID="1c419d6c-5064-4a2b-953c-05b2c67edb15" TYPE="xfs"
```

Определим UUID нового раздела:

```
blkid | grep md0
/dev/md0: UUID="73903146-9704-4fdb-a3e8-e871a48382db" TYPE="xfs"
```

Заменим UUID в конфигурационных файлах:

```
sed -i "s/1c419d6c-5064-4a2b-953c-05b2c67edb15/73903146-9704-4fdb-a3e8-e871a48382db/g" /mnt/etc/fstab
sed -i "s/1c419d6c-5064-4a2b-953c-05b2c67edb15/73903146-9704-4fdb-a3e8-e871a48382db/g" /mnt/boot/grub2/grub.cfg
```

Перемонтируем системную информацию:

```
mount --bind /sys /mnt/sys
mount --bind /proc /mnt/proc
mount --bind /dev /mnt/dev
mount --bind /run /mnt/run
mount --bind /boot /mnt/boot
```

Меняем корень на новый:

```
chroot /mnt
```

Собираем initramfs:

```
dracut --force /boot/initramfs-$(uname -r).img $(uname -r) -M
```

Добавим в командную строку запуска ядра параметр:

```
vim /etc/default/grub
GRUB_CMDLINE_LINUX=" ... rd.auto=1"
```

Параметр `rd.auto=1` включает автоматическую сборку специальных устройств, таких как mdraid, что позволяет выполнить с них загрузку. 

Создаем новую конфигурацию загрузчика grub:

```
grub2-mkconfig -o /boot/grub2/grub.cfg
```

Перезагружаемся (вернувшись на хостовую машину):

```
vagrant reload otuslinux-migrate-to-raid
```

После перезагрузки подключаемся к ВМ:

```
vagrant ssh otuslinux-migrate-to-raid
```

Прверяем, что загрузились с raid1:

```
lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda      8:0    0   40G  0 disk
L-sda1   8:1    0   40G  0 part
sdb      8:16   0  9.8G  0 disk
L-md0    9:0    0  9.8G  0 raid1 /
sdc      8:32   0  9.8G  0 disk
L-md0    9:0    0  9.8G  0 raid1 /
```

Видим, что корень расположен на raid1-массиве.