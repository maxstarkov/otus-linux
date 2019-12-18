## Решение задания

Скрипт выполняющий мониторинг файла лога расположен в файле `watchlog.sh`.
Установка скрипта и все подготовительные действия расположены в файле `install_watchlog.sh`.
Файл `install_watchlog.sh` добавлен в provision Vagrant-файла.

Для проверки задания нужно запустить ВМ:

```
vagrant up
```

После старта ВМ подключиться к ней через ssh:

```
vagrant ssh
```

Скрипт мониторинга будет установлен, а его выполнение добавлено в cron.
Проверим, что скрипт выполняется и отправляет email:

```
[vagrant@otuslinux ~]$ sudo mail
Heirloom Mail version 12.5 7/5/10.  Type ? for help.
"/var/spool/mail/vagrant": 6 messages 2 new 5 unread
 U  1 root                  Wed Dec 18 18:04 205/9639  "Wachlog"
 U  2 root                  Wed Dec 18 18:05  66/2460  "Wachlog"
    3 root                  Wed Dec 18 18:06  66/2461  "Wachlog"
 U  4 root                  Wed Dec 18 18:07  66/2460  "Wachlog"
>N  5 root                  Wed Dec 18 18:08  65/2450  "Wachlog"
 N  6 root                  Wed Dec 18 18:16  32/881   "Wachlog"
&
```

Видим, что оповещения успешно выполняются (возможно не сразу после загрузки системы, а в течение пары минут).
Если ввести номер сообщения, то можно будет прочитать текст оповещения.
