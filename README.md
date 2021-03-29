## Решение задания

Для проверки задания нужно запустить ВМ:

```
vagrant up
```

После запуска всех ВМ нужно выполнить [ansible playbook](./playbook.yml), который настроит dns:

```
ansible-playbook playbook.yml
```

Playbook выполняет следующие шаги:

- устанавливает необходимые пакеты (bind, bind-utils, chrony).
- устанавливает адреса dns серверов и имя домена.
- копирует конфигурационные файлы dns серверов.
- копирует файлы настройки dns зон.

Для проверки настроек dns зоны `newdns.lab` нужно выполнить команду:

```
ansible client1 -a "dig @192.168.50.10 newdns.lab. SOA"

client1 | CHANGED | rc=0 >>

; <<>> DiG 9.11.20-RedHat-9.11.20-5.el8_3.1 <<>> @192.168.50.10 newdns.lab. SOA
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57657
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 229b6fb1c449e5782f5cb3c060622903b5294244fe3ae0d6 (good)
;; QUESTION SECTION:
;newdns.lab.                    IN      SOA

;; ANSWER SECTION:
newdns.lab.             3600    IN      SOA     ns01.newdns.lab. root.newdns.lab. 2711201407 3600 600 86400 600

;; AUTHORITY SECTION:
newdns.lab.             3600    IN      NS      ns02.newdns.lab.
newdns.lab.             3600    IN      NS      ns01.newdns.lab.

;; ADDITIONAL SECTION:
ns01.newdns.lab.        3600    IN      A       192.168.50.10
ns02.newdns.lab.        3600    IN      A       192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Mon Mar 29 19:22:43 UTC 2021
;; MSG SIZE  rcvd: 178

```

Для проверки настройки записи www в зоне `newdns.lab` нужно выполнить команду:

```
ansible client1 -a "dig @192.168.50.10 www.newdns.lab. A"

client1 | CHANGED | rc=0 >>

; <<>> DiG 9.11.20-RedHat-9.11.20-5.el8_3.1 <<>> @192.168.50.10 www.newdns.lab. A
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56781
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 03a053973a65181a665de2f160622b806cf64bbe54d7d8c9 (good)
;; QUESTION SECTION:
;www.newdns.lab.                        IN      A

;; ANSWER SECTION:
www.newdns.lab.         3600    IN      A       192.168.50.15
www.newdns.lab.         3600    IN      A       192.168.50.16
...
```

Для проверки split-dns на `client1` нужно выполнить команды:

```
ansible client1 -a "ping -c 1 www.newdns.lab"

client1 | CHANGED | rc=0 >>
PING www.newdns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from client1 (192.168.50.15): icmp_seq=1 ttl=64 time=0.032 ms

--- www.newdns.lab ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.032/0.032/0.032/0.000 ms

ansible client1 -a "ping -c 1 web2"

client1 | FAILED | rc=2 >>
ping: web2: Name or service not knownnon-zero return code
```

Убеждаемся, что `client1` видит зону `newdns.lab`, а в зоне `dns.lab` НЕ видит хост `web2`

Для проверки split-dns на `client2` нужно выполнить команды:

```
ansible client2 -a "ping -c 1 web1"

client2 | CHANGED | rc=0 >>
PING web1.dns.lab (192.168.50.15) 56(84) bytes of data.
64 bytes from 192.168.50.15 (192.168.50.15): icmp_seq=1 ttl=64 time=0.708 ms

--- web1.dns.lab ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.708/0.708/0.708/0.000 ms

ansible client2 -a "ping -c 1 www.newdns.lab"

client2 | FAILED | rc=2 >>
ping: www.newdns.lab: Name or service not knownnon-zero return code
```

Убеждаемся, что `client2` НЕ видит зону `newdns.lab`, а в зоне `dns.lab` видит хост `web1`