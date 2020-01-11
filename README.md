## Решение задания

Для примера работы с процессами операционной системы реализованы два скрипта.

Скрипт `bps.sh` аналог команды `ps ax`. Реализован через получение информации о процессах из файловой системы `proc`.
Скрипт `run_load_script.sh` запускает в двух процессах скрипт `cpu_load.sh` с низким и обычным приоритетом для планировщика и выводит длительность работы каждого процесса.

Скрипты поддерживают опцию `-h | --help` для вывода справочной информации.
Скрипты `run_load_script` и `cpu_load` содержат обработчики сигналов SIGINT и SIGTERM, что гарантирует корректное завершение всех дочерних процессов.

Для проверки задания нужно запустить ВМ:

```
vagrant up
```

После старта ВМ подключиться к ней через ssh:

```
vagrant ssh
```

Скрипты будут расположены в каталоге `/vagrant`.

Запустить скрипт `bps.sh` можно следующим образом:

```
[vagrant@otuslinux ~]$ /vagrant/bps.sh
PID     TTY     STAT    TIME    COMMAND
1       0:0     S       0:02    /usr/lib/systemd/systemd--switched-root--system--deserialize21
2       0:0     S       0:00    (kthreadd)
3       0:0     S       0:00    (ksoftirqd/0)
4       0:0     S       0:00    (kworker/0:0)
5       0:0     S       0:00    (kworker/0:0H)
6       0:0     S       0:00    (kworker/u2:0)
...
3277    0:0     S       0:00    /sbin/dhclient-d-q-sf/usr/libexec/nm-dhcp-helper-pf/var/run/dhclient-eth0.pid-lf/var/lib/Networ
3953    0:0     S       0:00    sshd: vagrant [priv]
3956    0:0     S       0:00    sshd: vagrant@pts/0
3957    136:0   S       0:00    -bash
4256    136:0   S       0:00    -bash
```

Запустить скрипт `run_load_script.sh` можно следующим образом:

```
[vagrant@otuslinux ~]$ /vagrant/run_load_script.sh
Runed two process with low [PID=4511] and default [PID=4512] nice. Please wait for processes to complete or press CTRL+C.
Run with default nice. [PID=4512] Execution time - 1793 ms
Run with nice: 19. [PID=4511] Execution time - 3157 ms
```