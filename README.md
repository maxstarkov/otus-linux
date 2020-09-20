## Решение задания

Для проверки задания нужно запустить ВМ `log`, которая будет центральным сервером логов на основе `rsyslog`:

```
vagrant up log
```

При запуске ВМ `rsyslog` будет настроен на основе файла [rsyslog_server.conf](./rsyslog_server.conf).
Конфигурация сервера `rsyslog` определена в формате `RainerScript`.
Как результат, сервер будет прослушивать 514 порт, использовать протоколы tcp и udp, а полученные логи записывать в файлы по шаблону `/var/log/rsyslog/%HOSTNAME%/%PROGRAMNAME%.log`.

Будет выполнена настройка `auditd` для приема сообщений аудита с других хостов [log_auditd_settings.sh](./log_auditd_settings.sh).

Далее нужно запустить ВМ `web`:

```
vagrant up web
```

При запуске ВМ будет установлен `nginx` и применены настройки логирования из файла [nginx_log.conf](./nginx_log.conf).
Будет выполнена настройка `rsyslog` для отправки `crit` логов на сервер `log` (`echo "*.crit @@192.168.11.102:514" > /etc/rsyslog.d/crit.conf`).
Будет выполнена настройка для аудита доступа к файлу конфигурации nginx [web_auditd_settings.sh](./web_auditd_settings.sh).

Проверить отправку логов с уровнем `crit` можно следующей командой:

```
logger -p user.crit "Test critical message"
```

Команда `logger` выведет в системный журнал сообщение с уровнем `crit`.
Это сообщение будет передано на сервер `log` и записано в файл:

```
head /var/log/rsyslog/web/vagrant.log
2020-09-20T10:49:34+00:00 web vagrant: Test critical message
```

Логи веб-сервера `nginx` с ВМ `web` тоже будут находиться на центральном сервере логов:

```
head /var/log/rsyslog/web/nginx.log
2020-09-20T10:46:53+00:00 web nginx: 192.168.11.1 - - [20/Sep/2020:10:46:53 +0000] "GET / HTTP/1.1" 304 0 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:80.0) Gecko/20100101 Firefox/80.0"
...
```

Для проверки сбора сообщений аудита, на ВМ `web` нужно изменить файл конфигурации nginx.
На ВМ `log` можно увидеть события аудита для файла конфигурации nginx с хоста `web`:

```
tail -f /var/log/audit/audit.log
node=web type=PATH msg=audit(1600607770.146:1268): item=0 name="/etc/nginx/nginx.conf" inode=101362840 dev=08:01 mode=0100644 ouid=0 ogid=0 rdev=00:00 obj=unconfined_u:object_r:httpd_config_t:s0 objtype=NORMAL cap_fp=0000000000000000 cap_fi=0000000000000000 cap_fe=0 cap_fver=0OUID="root" OGID="root"
node=web type=PROCTITLE msg=audit(1600607770.146:1268): proctitle=7669002F6574632F6E67696E782F6E67696E782E636F6E66
node=web type=SYSCALL msg=audit(1600607770.146:1269): arch=c000003e syscall=90 success=yes exit=0 a0=a4a740 a1=81a4 a2=0 a3=24 items=1 ppid=4165 pid=4206 auid=1000 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=pts0 ses=4 comm="vi" exe="/usr/bin/vi" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="nginx_conf_change"ARCH=x86_64 SYSCALL=chmod AUID="vagrant" UID="root" GID="root" EUID="root" SUID="root" FSUID="root" EGID="root" SGID="root" FSGID="root"
...
```