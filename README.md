## Решение задания

## Попасть в систему без пароля

**Проблема**: слишком короткий таймаут для выбора загрузки в GRUB.
**Решение**: в файле `/etc/default/grub` установить таймаут в 10 секунд `GRUB_TIMEOUT=10`.

### Способ 1

Загружаем систему через GUI VirtualBox.
В диалоге выбора загрузки нажимаем клавишу `e` и переходим к редактированию параметров загрузки.
В конце строки начинающейся с linux16 добавляем `init=/bin/sh`.
Загружаемся через нажатие клавиш `ctrl+x`.

**Проблема**: В строке параметров запуска системы были параметры указания консоли и терминала, что не позволяло системе выполнить загрузку и она падала.
**Решение**: Удалить эти параметры из строки.

Корневая файловая система смонтирована в режиме read-only.
Можно перемонтировать ФС в режиме read-write с помощью команд:

```
mount -o remount,rw /
```

После чего можно редактировать любые файлы.

### Способ 2

Загружаемся аналогично способу 1 и переходим к редактированию параметров загрузки.
В конце строки загрузки ядра добавляем параметр `rd.break`.
Этот параметр ядра останавливает загрузку на этапе перед монтированием корневой ФС.
Загружаемся `ctrl+x`.
Монтируем корневую ФС, меняем корень:

```
mount -o remount,rw /sysroot
chroot /sysroot
```

Теперь можно менять пароль, например так:

```
echo "SuperStrongPassword" | passwd --stdin vagrant
```

Для борьбы с SELinux потребуется создать файл `.autorelabel`:

```
touch /.autorelabel
```

### Способ 3

Загружаемся аналогично способу 1 и переходим к редактированию параметров загрузки.
В этом способе сразу указываем в параметрах `init=/sysroot/bin/sh` и заменяем `ro` на `rw`.
Файловая система будет сразу смонтирована в режиме read-write.
Дальнейшие действия по смене пароля аналогичны.

В предыдущих примерах тоже можно заменить `ro` на `rw` и получить доступ на чтение-запись.

## Переименовать VG

Сначала узнаем какие volume group есть в системе выполнив команду `vgs`:

```
[root@lvm ~]# vgs
  VG         #PV #LV #SN Attr   VSize   VFree
  VolGroup00   1   2   0 wz--n- <38.97g    0
```

Переименуем нужную нам VG (VolGroup00) в OtusRoot.
Для этого выполним команду `vgrename VolGroup00 OtusRoot`:

```
[root@lvm ~]# vgrename VolGroup00 OtusRoot
  Volume group "VolGroup00" successfully renamed to "OtusRoot"
```

Исправим имя VG в файлах `/etc/fstab, /etc/default/grub, /boot/grub2/grub2.cfg`:

```
[root@lvm ~]# vi /etc/fstab
[root@lvm ~]# vi /etc/default/grub
[root@lvm ~]# vi /boot/grub2/grub.cfg
```

Создадим initrd для нового названия VG:

```
[root@lvm ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
```

Перезагружаемся и проверяем имя VG:

```
[root@lvm ~]# vgs
  VG       #PV #LV #SN Attr   VSize   VFree
  OtusRoot   1   2   0 wz--n- <38.97g    0
```

## Добавить модуль в initrd

Для добавления своего модуля в initrd нужно создать подкаталог в каталоге `/usr/lib/dracut/modules.d/`:

```
[root@lvm ~]# mkdir /usr/lib/dracut/modules.d/01otus-test
[root@lvm ~]# cd /usr/lib/dracut/modules.d/01otus-test
```

В каталоге создаем два файла `module-setup.sh` и `otus-test.sh`:

```
[root@lvm 01otus-test]# cat module-setup.sh

#!/bin/bash

check() {
    return 0
}

depends() {
    return 0
}

install() {
    inst_hook cleanup 00 "${moddir}/otus-test.sh"
}

[root@lvm 01otus-test]# cat otus-test.sh

#!/bin/bash

exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in Otus-test dracut module!
 _____________________________
< I'm Otus-test dracut module >
 -----------------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
```

Пересобираем initrd командой:

```
[root@lvm ~]# dracut -f -v
```

Проверяем, что модуль в initrd:

```
[root@lvm ~]# lsinitrd -m /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img | grep otus-test
otus-test
```

Удалим параметр загрузки `quiet`, либо через редактирование файла `/etc/default/grub`, либо в момент загрузки.

В итоге при загрузке будет выведена картинка из модуля и сделана пауза на 10 секунд.
