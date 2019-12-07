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

### Задание 2

Конфигурация модуля сервиса расположена в файле `spawn-fcgi.service`.

Скрипт установки модуля и его активации расположен в файле `systemd_spawn_fcgi.sh`.

Запуск скрипта добавлен в provision Vagrant-файла.

Для проверки задания нужно запустить ВМ как в предыдущем задании и выполнить команду:

```
[vagrant@otuslinux ~]$ systemctl status spawn-fcgi.service
? spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-12-07 15:11:00 UTC; 20s ago
 Main PID: 6571 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           +-6571 /usr/bin/php-cgi
           +-6574 /usr/bin/php-cgi
           +-6575 /usr/bin/php-cgi
           +-6576 /usr/bin/php-cgi
           +-6577 /usr/bin/php-cgi
           +-6578 /usr/bin/php-cgi
           +-6579 /usr/bin/php-cgi
           +-6580 /usr/bin/php-cgi
           +-6581 /usr/bin/php-cgi
           +-6582 /usr/bin/php-cgi
           +-6583 /usr/bin/php-cgi
           +-6584 /usr/bin/php-cgi
```

### Задание 3

Скрипт установки модуля и его активации расположен в файле `systemd_httpd_template.sh`

Запуск скрипта добавлен в provision Vagrant-файла.

Для проверки задания нужно запустить ВМ как в предыдущем задании и выполнить команды:

```
[root@otuslinux ~]# systemctl status httpd@first.service
? httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-12-07 18:06:04 UTC; 16min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 5485 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           +-5485 /usr/sbin/httpd -f conf/httpd_first.conf -DFOREGROUND
           +-5486 /usr/sbin/httpd -f conf/httpd_first.conf -DFOREGROUND
           +-5487 /usr/sbin/httpd -f conf/httpd_first.conf -DFOREGROUND
           +-5488 /usr/sbin/httpd -f conf/httpd_first.conf -DFOREGROUND
           +-5489 /usr/sbin/httpd -f conf/httpd_first.conf -DFOREGROUND
           +-5490 /usr/sbin/httpd -f conf/httpd_first.conf -DFOREGROUND
           L-5491 /usr/sbin/httpd -f conf/httpd_first.conf -DFOREGROUND

Dec 07 18:06:04 otuslinux systemd[1]: Starting The Apache HTTP Server...
Dec 07 18:06:04 otuslinux httpd[5485]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 12... message
Dec 07 18:06:04 otuslinux systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```

```
[root@otuslinux ~]# systemctl status httpd@second.service
? httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2019-12-07 18:06:11 UTC; 16min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 5502 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           +-5502 /usr/sbin/httpd -f conf/httpd_second.conf -DFOREGROUND
           +-5503 /usr/sbin/httpd -f conf/httpd_second.conf -DFOREGROUND
           +-5504 /usr/sbin/httpd -f conf/httpd_second.conf -DFOREGROUND
           +-5505 /usr/sbin/httpd -f conf/httpd_second.conf -DFOREGROUND
           +-5506 /usr/sbin/httpd -f conf/httpd_second.conf -DFOREGROUND
           +-5507 /usr/sbin/httpd -f conf/httpd_second.conf -DFOREGROUND
           L-5508 /usr/sbin/httpd -f conf/httpd_second.conf -DFOREGROUND

Dec 07 18:06:11 otuslinux systemd[1]: Starting The Apache HTTP Server...
Dec 07 18:06:11 otuslinux httpd[5502]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 12... message
Dec 07 18:06:11 otuslinux systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```

Видим, что запущено два экземпляра httpd с разными конфигурациями.
Для дополнительной проверки можно выполнить команду:

```
[root@otuslinux ~]# ss -tnulp | grep httpd
tcp    LISTEN     0      128      :::8008                 :::*                   users:(("httpd",pid=5508,fd=4),("httpd",pid=5507,fd=4),("httpd",pid=5506,fd=4),("httpd",pid=5505,fd=4),("httpd",pid=5504,fd=4),("httpd",pid=5503,fd=4),("httpd",pid=5502,fd=4))
tcp    LISTEN     0      128      :::8080                 :::*                   users:(("httpd",pid=5491,fd=4),("httpd",pid=5490,fd=4),("httpd",pid=5489,fd=4),("httpd",pid=5488,fd=4),("httpd",pid=5487,fd=4),("httpd",pid=5486,fd=4),("httpd",pid=5485,fd=4))
```

Видим, что экземпляры httpd работают и слушают разные порты - 8008 и 8080 соответственно.
