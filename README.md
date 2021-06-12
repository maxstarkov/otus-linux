## Решение задания

Файл конфигурации packer'а переделан для создания образа через Vagrant Builder.

Vagrant Builder позволяет собирать новые образы на основе существующих.

За основу берется базовый образ `centos/7`, для которого выполняются `provisioners`:

- Обновление ядра [stage-1-kernel-update.sh](./packer/scripts/stage-1-kernel-update.sh). 
- Сборка и установка дополнений гостевой ОС [stage-1-2-vbguest-update.sh](./packer/scripts/stage-1-2-vbguest-update.sh).
- Очистка и подготовка образа [stage-2-clean.sh](./packer/scripts/stage-2-clean.sh).

Для сборки образа нужно установить `packer`, перейти в каталог `packer` и выполнить команду:

```
packer build centos.json
```

После выполнения сборки, новый образ будет расположен в файле `packer/output-centos-7.7/package.box`

Готовый образ с обновленным ядром и дополнениями гостевой ОС доступен по ссылке: [maxst/centos-7-5](https://app.vagrantup.com/maxst/boxes/centos-7-5)

Для проверки задания нужно выполнить команды:

```
vagrant init maxst/centos-7-5
vagrant up
```

После чего будет создана ВМ на основе образа `maxst/centos-7-5`.
Установленные дополнения гостевой ОС позволяют обмениваться файлами с хостовой ОС.

Для проверки нужно подключиться к созданной ВМ через ssh:

```
vagrant ssh
```

Выполнить команду создания файла в каталоге `/vagrant`:

```
touch /vagrant/test.file
```

На хостовой ОС проверить наличие файла в каталоге ВМ:

```
$ ll test.file
-rw-r--r-- 1 user 197609 0 may 26 23:03 test.file
```

Для проверки версии ядра нужно выполнить команду:

```
uname -r
5.12.10-1.el7.elrepo.x86_64
```