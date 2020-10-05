## Решение задания

Для проверки задания нужно запустить ВМ `backup_server`, которая будет центральным сервером для хранения резервных копий:

```
vagrant up backup_server
```

При запуске ВМ с помощью shell provisions будут выполнены:

- Подготовка диска `sdb` для хранения бекапов. На диске будет создана файловая система `xfs`, а диск смонтирован в каталог `/var/backup`.
- Установлен mount-unit для автоматического монтирования диска [var-backup.mount](./var-backup.mount).
- Установлен пакет `borgbackup` из репозитория `epel-release`.

Центральный сервер для хранения логов на ВМ `backup_server` готов.

Далее нужно запустить ВМ `backup_client`:

```
vagrant up backup_client
```

При запуске ВМ с помощью shell provisions будут выполнены:

- Скопирован закрытый ssh ключ с помощью которого можно подключиться к ВМ `backup_server`.
- Установлен пакет `borgbackup` из репозитория `epel-release`.
- Инициализирован репозиторий для хранения архивов на ВМ `backup_server`.
- Установлен скрипт [borg_backup.sh](./borg_backup.sh) для автоматического создания резервных копий.
- Установлен timer-unit для автоматического запуска скрипта бекапа: [borg-backup.service](./borg-backup.service) [borg-backup.timer](./borg-backup.timer)

После запуска ВМ `backup_client` автоматически начнут создаваться резервные копии каталога `/etc` каждые 5 минут.

Логи процесса созданий резервных копий можно посмотреть в журнале systemd:

```
journalctl -u borg-backup.service
...
Oct 04 12:25:07 backupclient borg_backup.sh[4085]: A /etc/selinux/targeted/active/modules/100/mip6d/lang_ext
Oct 04 12:25:07 backupclient borg_backup.sh[4085]: A /etc/selinux/targeted/active/modules/100/modemmanager/cil
Oct 04 12:25:07 backupclient borg_backup.sh[4085]: A /etc/selinux/targeted/active/modules/100/modemmanager/hll
Oct 04 12:25:11 backupclient borg_backup.sh[4085]: Sun Oct  4 12:25:11 UTC 2020 Backup and Prune finished successfully
```

Список архивов в репозитории можно получить с помощью команды:

```
borg list ssh://vagrant@192.168.11.101/var/backup
Enter passphrase for key ssh://vagrant@192.168.11.101/var/backup:
backupclient-2020-10-04T12:30:06     Sun, 2020-10-04 12:30:07 [e9cfa999b96ccc92a7ec4c473904832fee40cfd4e090ef2f68400a8c6ddd102e]
```