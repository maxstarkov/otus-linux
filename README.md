## Решение задания

Для проверки задания нужно запустить ВМ:

```
vagrant up
```

При запуске ВМ будут установлены вспомогательные утилиты для работы с SELinux и nginx.

Попробуем запустить nginx на порту 1111. Изменим порт в настроках веб-сервера:

```
sed -i -r 's/listen\s+80 default_server;/listen 1111 default_server;/' /etc/nginx/nginx.conf
sed -i -r 's/listen\s+\[::\]:80 default_server;/listen [::]:1111 default_server;/' /etc/nginx/nginx.conf
```

Попробуем запустить веб-сервер и получим сообщение об ошибке запуска процесса:

```
systemctl start nginx.service
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
```

Проверим статус службы:

```
systemctl status nginx.service
? nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2020-08-31 19:56:17 UTC; 12s ago
  Process: 25361 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 25360 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 24950 (code=exited, status=0/SUCCESS)

Aug 31 19:56:17 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 31 19:56:17 localhost.localdomain nginx[25361]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 31 19:56:17 localhost.localdomain nginx[25361]: nginx: [emerg] bind() to 0.0.0.0:1111 failed (13: Permission denied)
Aug 31 19:56:17 localhost.localdomain nginx[25361]: nginx: configuration file /etc/nginx/nginx.conf test failed
Aug 31 19:56:17 localhost.localdomain systemd[1]: nginx.service: control process exited, code=exited status=1
Aug 31 19:56:17 localhost.localdomain systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Aug 31 19:56:17 localhost.localdomain systemd[1]: Unit nginx.service entered failed state.
Aug 31 19:56:17 localhost.localdomain systemd[1]: nginx.service failed.
```

Вывод также указывает на ошибку при попытке привязки порта 1111.

С помощью утилиты `sealert` получим информацию о возможных способах исправления ситуации:

```
sealert -a /var/log/audit/audit.log
100% done
found 1 alerts in /var/log/audit/audit.log
--------------------------------------------------------------------------------

SELinux is preventing /usr/sbin/nginx from name_bind access on the tcp_socket port 1111.

*****  Plugin bind_ports (92.2 confidence) suggests   ************************

If you want to allow /usr/sbin/nginx to bind to network port 1111
Then you need to modify the port type.
Do
# semanage port -a -t PORT_TYPE -p tcp 1111
    where PORT_TYPE is one of the following: http_cache_port_t, http_port_t, jboss_management_port_t, jboss_messaging_port_t, ntop_port_t, puppet_port_t.

*****  Plugin catchall_boolean (7.83 confidence) suggests   ******************

If you want to allow nis to enabled
Then you must tell SELinux about this by enabling the 'nis_enabled' boolean.

Do
setsebool -P nis_enabled 1

*****  Plugin catchall (1.41 confidence) suggests   **************************

If you believe that nginx should be allowed name_bind access on the port 1111 tcp_socket by default.
Then you should report this as a bug.
You can generate a local policy module to allow this access.
Do
allow this access for now by executing:
# ausearch -c 'nginx' --raw | audit2allow -M my-nginx
# semodule -i my-nginx.pp
...
```

Воспользуемся самым надежным из предложенных способов - добавим порт 1111 в тип `http_port_t`:

```
semanage port -a -t http_port_t -p tcp 1111
```

После изменений в настройках типа, проверим возможность работы веб-сервера:

```
systemctl restart nginx.service

systemctl status nginx.service
? nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-08-31 20:05:44 UTC; 4s ago
  Process: 25476 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25474 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 25473 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25478 (nginx)
   CGroup: /system.slice/nginx.service
           +-25478 nginx: master process /usr/sbin/nginx
           L-25479 nginx: worker process

Aug 31 20:05:44 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 31 20:05:44 localhost.localdomain nginx[25474]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 31 20:05:44 localhost.localdomain nginx[25474]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Aug 31 20:05:44 localhost.localdomain systemd[1]: Failed to parse PID from file /run/nginx.pid: Invalid argument
Aug 31 20:05:44 localhost.localdomain systemd[1]: Started The nginx HTTP and reverse proxy server.

ss -tulpn | grep nginx
tcp    LISTEN     0      128       *:1111                  *:*                   users:(("nginx",pid=25479,fd=6),("nginx",pid=25478,fd=6))
tcp    LISTEN     0      128    [::]:1111               [::]:*                   users:(("nginx",pid=25479,fd=7),("nginx",pid=25478,fd=7))

```

Видим, что nginx успешно запущен и прослушивает порт 1111.

Убедимся, что порт 1111 добавлен в настройки типа `http_port_t`:

```
semanage port -l | grep http_port_t
http_port_t                    tcp      1111, 80, 81, 443, 488, 8008, 8009, 8443, 9000
```

Для проверки других способов настройки SELinux удалим порт из настроек типа `http_port_t`:

```
semanage port -d -t http_port_t -p tcp 1111

semanage port -l | grep http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000

systemctl restart nginx.service
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

systemctl status nginx.service
? nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2020-08-31 20:16:37 UTC; 22s ago
  Process: 25476 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25519 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 25517 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25478 (code=exited, status=0/SUCCESS)

Aug 31 20:16:37 localhost.localdomain systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Aug 31 20:16:37 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 31 20:16:37 localhost.localdomain nginx[25519]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 31 20:16:37 localhost.localdomain nginx[25519]: nginx: [emerg] bind() to 0.0.0.0:1111 failed (13: Permission denied)
Aug 31 20:16:37 localhost.localdomain nginx[25519]: nginx: configuration file /etc/nginx/nginx.conf test failed
Aug 31 20:16:37 localhost.localdomain systemd[1]: nginx.service: control process exited, code=exited status=1
Aug 31 20:16:37 localhost.localdomain systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Aug 31 20:16:37 localhost.localdomain systemd[1]: Unit nginx.service entered failed state.
Aug 31 20:16:37 localhost.localdomain systemd[1]: nginx.service failed.
```

Порт удален из настроек типа и веб-сервис не может быть запущен с прослушиванием порта 1111.

Второй способ предлагает использовать переключатель `nis_enabled`:

```
setsebool -P nis_enabled 1

systemctl restart nginx.service

systemctl status nginx.service
? nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-08-31 20:26:15 UTC; 3s ago
  Process: 25557 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25554 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 25553 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25559 (nginx)
   CGroup: /system.slice/nginx.service
           +-25559 nginx: master process /usr/sbin/nginx
           L-25560 nginx: worker process

Aug 31 20:26:15 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 31 20:26:15 localhost.localdomain nginx[25554]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 31 20:26:15 localhost.localdomain nginx[25554]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Aug 31 20:26:15 localhost.localdomain systemd[1]: Failed to parse PID from file /run/nginx.pid: Invalid argument
Aug 31 20:26:15 localhost.localdomain systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Видим, что nginx успешно запущен и прослушивает порт 1111.

Отключим переключатель `nis_enabled`:

```
setsebool -P nis_enabled 0

systemctl restart nginx.service
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

systemctl status nginx.service
? nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2020-08-31 20:30:49 UTC; 2s ago
  Process: 25557 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25578 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 25576 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25559 (code=exited, status=0/SUCCESS)

Aug 31 20:30:48 localhost.localdomain systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Aug 31 20:30:49 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 31 20:30:49 localhost.localdomain nginx[25578]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 31 20:30:49 localhost.localdomain nginx[25578]: nginx: [emerg] bind() to 0.0.0.0:1111 failed (13: Permission denied)
Aug 31 20:30:49 localhost.localdomain nginx[25578]: nginx: configuration file /etc/nginx/nginx.conf test failed
Aug 31 20:30:49 localhost.localdomain systemd[1]: nginx.service: control process exited, code=exited status=1
Aug 31 20:30:49 localhost.localdomain systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Aug 31 20:30:49 localhost.localdomain systemd[1]: Unit nginx.service entered failed state.
Aug 31 20:30:49 localhost.localdomain systemd[1]: nginx.service failed.
```

Выключенный переключатель не позволяет SELinux запустить веб-сервере с прослушиванием порта 1111.

Третий способ предлагает собрать модуль локальной политики SELinux для обеспечения работы nginx на нестандартном порту:

```
ausearch -c 'nginx' --raw | audit2allow -M otus-nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i otus-nginx.pp

semodule -i otus-nginx.pp

systemctl restart nginx.service

systemctl status nginx.service
? nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Mon 2020-08-31 20:40:26 UTC; 3s ago
  Process: 25642 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25639 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 25638 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25644 (nginx)
   CGroup: /system.slice/nginx.service
           +-25644 nginx: master process /usr/sbin/nginx
           L-25645 nginx: worker process

Aug 31 20:40:26 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 31 20:40:26 localhost.localdomain nginx[25639]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 31 20:40:26 localhost.localdomain nginx[25639]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Aug 31 20:40:26 localhost.localdomain systemd[1]: Failed to parse PID from file /run/nginx.pid: Invalid argument
Aug 31 20:40:26 localhost.localdomain systemd[1]: Started The nginx HTTP and reverse proxy server.
```

Созданный модуль локальной политики на основе логов SELinux позволяет запускать nginx с прослушиванием порта 1111.

Удалим модуль и вернем систему в исходное состояние:

```
semodule -r otus-nginx

systemctl restart nginx.service
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.

systemctl status nginx.service
? nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Mon 2020-08-31 20:44:24 UTC; 3s ago
  Process: 25642 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 25672 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=1/FAILURE)
  Process: 25670 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 25644 (code=exited, status=0/SUCCESS)

Aug 31 20:44:24 localhost.localdomain systemd[1]: Stopped The nginx HTTP and reverse proxy server.
Aug 31 20:44:24 localhost.localdomain systemd[1]: Starting The nginx HTTP and reverse proxy server...
Aug 31 20:44:24 localhost.localdomain nginx[25672]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Aug 31 20:44:24 localhost.localdomain nginx[25672]: nginx: [emerg] bind() to 0.0.0.0:1111 failed (13: Permission denied)
Aug 31 20:44:24 localhost.localdomain nginx[25672]: nginx: configuration file /etc/nginx/nginx.conf test failed
Aug 31 20:44:24 localhost.localdomain systemd[1]: nginx.service: control process exited, code=exited status=1
Aug 31 20:44:24 localhost.localdomain systemd[1]: Failed to start The nginx HTTP and reverse proxy server.
Aug 31 20:44:24 localhost.localdomain systemd[1]: Unit nginx.service entered failed state.
Aug 31 20:44:24 localhost.localdomain systemd[1]: nginx.service failed.
```

Первый способ обеспечивает максимальную безопасность, остальные способы не так надежны и не рекомендованы к использованию.

## Решение дополнительного задания

Для решения задания был развернут [стенд](https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems).

Подключившись к ВМ `client` и попытке выполнить команду изменения в зоне `ddns.lab` происходит следующее:

```
nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
update failed: SERVFAIL
```

Судя по выводу команды ошибка происходит при работе службы разрешения имен на сервере 192.168.50.10 (это ВМ `ns01`).

Подключившись к ВМ `ns01` проверим логи SELinux с помощью утилиты `sealert`:

```
sudo sealert -a /var/log/audit/audit.log
100% done
found 2 alerts in /var/log/audit/audit.log
--------------------------------------------------------------------------------

SELinux is preventing /usr/sbin/named from write access on the directory named.

*****  Plugin catchall_boolean (89.3 confidence) suggests   ******************

If you want to allow named to write master zones
Then you must tell SELinux about this by enabling the 'named_write_master_zones' boolean.

Do
setsebool -P named_write_master_zones 1

...

--------------------------------------------------------------------------------

SELinux is preventing /usr/sbin/named from create access on the file named.ddns.lab.view1.jnl.

*****  Plugin catchall_labels (83.8 confidence) suggests   *******************

If you want to allow named to have create access on the named.ddns.lab.view1.jnl file
Then you need to change the label on named.ddns.lab.view1.jnl
Do
# semanage fcontext -a -t FILE_TYPE 'named.ddns.lab.view1.jnl'
where FILE_TYPE is one of the following: dnssec_trigger_var_run_t, ipa_var_lib_t, krb5_host_rcache_t, krb5_keytab_t, named_cache_t, named_log_t, named_tmp_t, named_var_run_t.
Then execute:
restorecon -v 'named.ddns.lab.view1.jnl'
...

```

Действительно, на сервере обнаружено две проблемы и предложены самые подходящие способы их решения.
Проблемы связаны с невозможностью выполнить операции доступа к некоторым ресурсам для процесса `/usr/sbin/named`.

Первый вариант решения проблемы, это воспользоваться переключателем `named_write_master_zones`.
Посмотрим описание этого переключателя:

```
semanage boolean --list | grep named_write_master_zones
named_write_master_zones       (off  ,  off)  Allow named to write master zones
```

Этот переключатель позволяет `named` выполнять запись в необходимые ресурсы.

Включим переключатель `named_write_master_zones`:

```
setsebool -P named_write_master_zones 1
```

После включения переключателя снова выполним на ВМ `client` команду `nsupdate` и снова получим сообщение об ошибке.

В выводе команды `sealert` на ВМ `ns01` было указано о ещё одном ограничении SELinux для процесса `named` связанной с доступом к файлу `named.ddns.lab.view1.jnl`. Это файл лога автоматически формируемый службой DNS сервера при обновлении записей имен. Судя по настройкам `named` для зоны `ddns.lab` файл лога должен быть сформирован в каталоге `/etc/named/dynamic/`.
Узнаем контекст SELinux для каталога:

```
ls -lZ /etc/named/dynamic/
-rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
-rw-r--r--. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1
```

Тип (домен) SELinux для доступа к этому каталогу - `etc_t`, однако его нет в рекомендациях к настройке SELinux из результатов команды `sealert`. Это связанно с некорректной настройкой `named`, файлы настроек зоны `ddns.lab` нужно было размещать в каталоге `/var/named/`.
Типы (домены) дочерних каталогов входят в перечень рекомендуемых (тип `named_cache_t`):

```
 ls -lZ /var/named/
drwxrwx---. named named system_u:object_r:named_cache_t:s0 data
drwxrwx---. named named system_u:object_r:named_cache_t:s0 dynamic
-rw-r-----. root  named system_u:object_r:named_conf_t:s0 named.ca
-rw-r-----. root  named system_u:object_r:named_zone_t:s0 named.empty
-rw-r-----. root  named system_u:object_r:named_zone_t:s0 named.localhost
-rw-r-----. root  named system_u:object_r:named_zone_t:s0 named.loopback
drwxrwx---. named named system_u:object_r:named_cache_t:s0 slaves
```

Проблема работы сервиса установлена, но правильная настройка `named` это отдельная тема.