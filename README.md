## Решение задания

Для проверки выполнения задания нужно выполнить команду:

```
vagrant up --provision-with copy_root
```

Будет создана ВМ и запущен provision shell-скрипт [copy_root.sh](./copy_root.sh), который перенесет корневой раздел на временный logical volume.

Далее нужно выполнить команду:

```
vagrant reload --provision-with resize_root
```

ВМ будет перезагружена и запущен provision shell-скрипт [resize_root.sh](./resize_root.sh), который пересоздаст старый logical volume с необходимым размером (8ГБ) и создаст файловую систему.

Далее нужно выполнить команду:

```
vagrant reload --provision-with restore_root
```

ВМ будет перезагружена и запущен provision shell-скрипт [restore_root.sh](./restore_root.sh), который восстановит корневой раздел на новый, уже уменьшенный, logical volume.

Далее нужно выполнить команду:

```
vagrant reload --provision-with move_var_dir
```

ВМ будет перезагружена и запущен provision shell-скрипт [move_var_dir.sh](./move_var_dir.sh), который перенесет раздел `var` на новый mirrored logical volume.

Далее нужно выполнить команду:

```
vagrant reload --provision-with move_home_dir
```

ВМ будет перезагружена и запущен provision shell-скрипт [move_home_dir.sh](./move_home_dir.sh), который перенесет раздел `home` на новый logical volume для работы со снимками.

Далее нужно выполнить команду:

```
vagrant reload --provision-with remove_temp_vg
```

ВМ будет перезагружена и запущен provision shell-скрипт [remove_temp_vg.sh](./remove_temp_vg.sh), который удалит временный logical volume использованный для переноса корня.

Для проверки работы со снимками создадим в каталоге `/home/vagrant` несколько файлов:

```
touch /home/vagrant/file{1..10}
```

Сделаем снимок каталога `/home/vagrant`:

```
lvcreate -L 100MB -s -n vagrant_snap /dev/VolGroup00/LogVol_Home
```

Удалим часть файлов:

```
rm -f /home/vagrant/file{1..5}
ll /home/vagrant/
total 0
-rw-r--r--. 1 root root 0 Jun  1 19:46 file10
-rw-r--r--. 1 root root 0 Jun  1 19:46 file6
-rw-r--r--. 1 root root 0 Jun  1 19:46 file7
-rw-r--r--. 1 root root 0 Jun  1 19:46 file8
-rw-r--r--. 1 root root 0 Jun  1 19:46 file9
```

При работе через пользователя `vagarnt`, файлы в каталоге `home` будут заняты, поэтому не получится его отмонтировать.
Для восстановления потребуется зайти в ВМ напрямую через VirtualBox под пользователем root.

Восстановим данные со снимка:

```
umount /home
lvconvert --merge /dev/VolGroup00/vagrant_snap
mount /home
```

Убеждаемся, что файлы восстановлены:

```
ll /home/vagrant/
total 0
-rw-r--r--. 1 root root 0 Jun  1 19:46 file1
-rw-r--r--. 1 root root 0 Jun  1 19:46 file10
-rw-r--r--. 1 root root 0 Jun  1 19:46 file2
-rw-r--r--. 1 root root 0 Jun  1 19:46 file3
-rw-r--r--. 1 root root 0 Jun  1 19:46 file4
-rw-r--r--. 1 root root 0 Jun  1 19:46 file5
-rw-r--r--. 1 root root 0 Jun  1 19:46 file6
-rw-r--r--. 1 root root 0 Jun  1 19:46 file7
-rw-r--r--. 1 root root 0 Jun  1 19:46 file8
-rw-r--r--. 1 root root 0 Jun  1 19:46 file9
```