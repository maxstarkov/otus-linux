## Решение задания

Для проверки задания нужно запустить ВМ `nfs_server`:

```
vagrant up nfs_server
```

При первом запуске ВМ все необходимое для работы nfs будет установлено и настроено с помощью shell provision.

Shell provision установит необходимые пакеты:

```
yum -y install nfs-utils rpcbind
```

Будут запущены сервисы firewall, nfs-server и rpcbind:

```
systemctl enable firewalld --now
systemctl enable nfs-server --now
systemctl enable rpcbind
```

Сконфигурирваны настройки firewall для работы nfs версии 3:

```
firewall-cmd --permanent --add-service nfs
firewall-cmd --permanent --add-service mountd
firewall-cmd --permanent --add-service rpc-bind
firewall-cmd --permanent --add-port=2049/udp
firewall-cmd --reload
```

Созданы каталоги для экспорта через nfs:

```
mkdir -p /var/nfs/nfs_share
mkdir -p /var/nfs/upload
```

В файл `/etc/exports` будут добавлены настройки экспорта:

```
echo "/var/nfs/nfs_share 192.168.11.102(ro,no_root_squash)" >> /etc/exports
echo "/var/nfs/upload 192.168.11.102(rw,no_root_squash)" >> /etc/exports
```

Каталог `/var/nfs/nfs_share` экспортируется с опцией только для чтения.
Каталог `/var/nfs/upload` экспортируется с опцией чтение-запись.

Обновлены данные для экспорта:

```
exportfs -r
```

Далее нужно запустить ВМ `nfs_client`:

```
vagrant up nfs_client
```

При первом запуске ВМ все необходимое для работы клиента nfs будет установлено и настроено с помощью shell provision.

Shell provision создаст каталоги в которые будут примонтированы экспортированные каталоги:

```
mkdir -p /nfs/nfs_share
mkdir -p /nfs/upload
```

Добавит записи в файл `/etc/fstab` и запустит монтирование:

```
echo "192.168.11.101:/var/nfs/nfs_share /nfs/nfs_share nfs defaults,soft,nfsvers=3,udp 0 0" >> /etc/fstab
echo "192.168.11.101:/var/nfs/upload /nfs/upload nfs defaults,soft,nfsvers=3,udp 0 0" >> /etc/fstab
mount -a
```

Настройки монтирования указывают применять 3 версию протокола NFS, а в качестве транспортного протокола использовать UDP.

После запуска всех ВМ и выполнения настроек можно проверить работу NFS.

На клиенте создадим файл в каталоге доступном на запись:

```
[root@nfsclient ~]# echo "TEST" > /nfs/upload/test.file
```

На сервере прочитаем файл:

```
[vagrant@nfsserver ~]$ cat /var/nfs/upload/test.file
TEST
```

Создадим файл на сервере в каталоге, который экспортируется только на чтение:

```
[root@nfsserver ~]# echo "TEST READ-ONLY" > /var/nfs/nfs_share/test.file
```

На клиенте прочитаем файл:

```
[root@nfsclient ~]# cat /nfs/nfs_share/test.file
TEST READ-ONLY
```

Попробуем добавить в этот файл на клиенте строку:

```
[root@nfsclient ~]# echo "ADD LINE" >> /nfs/nfs_share/test.file
-bash: /nfs/nfs_share/test.file: Permission denied
```

Как и ожидалось - получим ошибку записи. Каталог экспортирован только на чтение.