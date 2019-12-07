## Решение задания

### Задание 1

Настройки модуля для мониторинга файла лога расположены в файле `watchlog`.
Конфигурация модуля таймера расположена в файле `watchlog.timer`.
Конфигурация модуля сервиса расположена в файле `watchlog.service`.

Скрипт установки модуля и его активации расположен в файле `systemd_watchlog.sh`.

Запуск скрипта добавлен в provision Vagrant-файла.

Для проверки задания нужно запустить ВМ:

```
vagrant up
```

После старта ВМ подключиться к ней через ssh:

```
vagrant ssh
```

Модуль таймера уже будет установлен.
Проверим, что таймер активен:

```
[root@otuslinux ~]# systemctl list-timers
NEXT                         LEFT          LAST                         PASSED UNIT                         ACTIVATES
Sat 2019-12-07 14:04:56 UTC  8s left       Sat 2019-12-07 14:04:46 UTC  1s ago watchlog.timer               watchlog.service
Sat 2019-12-07 14:07:10 UTC  2min 22s left n/a                          n/a    systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
```

Видим, что таймер `watchlog.timer` выполняется.

Проверим вывод сообщений в системный лог:

```
[root@otuslinux ~]# tail -f /var/log/messages
Dec  7 14:03:36 otuslinux systemd: Started Example watchlog service.
Dec  7 14:04:34 otuslinux systemd: Starting Example watchlog service...
Dec  7 14:04:34 otuslinux root: Sat Dec  7 14:04:34 UTC 2019: Found word: ALERT in log file: /var/log/watchlog.log
Dec  7 14:04:34 otuslinux systemd: Started Example watchlog service.
Dec  7 14:04:46 otuslinux systemd: Starting Example watchlog service...
Dec  7 14:04:46 otuslinux root: Sat Dec  7 14:04:46 UTC 2019: Found word: ALERT in log file: /var/log/watchlog.log
Dec  7 14:04:46 otuslinux systemd: Started Example watchlog service.
Dec  7 14:05:46 otuslinux systemd: Starting Example watchlog service...
Dec  7 14:05:46 otuslinux root: Sat Dec  7 14:05:46 UTC 2019: Found word: ALERT in log file: /var/log/watchlog.log
Dec  7 14:05:46 otuslinux systemd: Started Example watchlog service.
```
