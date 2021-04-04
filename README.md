## Решение задания

Для проверки задания нужно запустить ВМ:

```
vagrant up
```

После запуска всех ВМ нужно выполнить [ansible playbook](./playbook.yml), который настроит сеть:

```
ansible-playbook playbook.yml
```

Playbook выполняет следующие шаги:

- пересоздает соединения с учетом имени интерфейса.
- создает bound'ы и добавляет к ним интерфейсы.
- создает vlan'ы.
- назначает ip адреса для соединений.
- удаляет маршрут по умолчанию с интерфейса eth0.
- устанавливает правильный адрес шлюза.
- добавляет маршруты.
- настраивает firewall.

Для проверки состояния bond'а между ВМ `inetRouter` и `centralRouter` нужно выполнить команду, например на ВМ `inetRouter`:

```
[root@inetRouter ~]# cat /proc/net/bonding/bond0 
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Peer Notification Delay (ms): 0

Slave Interface: eth1
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:5c:9a:ef
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:e9:2d:ef
Slave queue ID: 0
```

Видим, что текущее активное соединение на интерфейсе `eth1`.
На ВМ `centralRouter` выполним команду:

```
[root@centralRouter ~]# ping 192.168.255.1
```

На ВМ `inetRouter` выключим интерфейс `eth1`:

```
[root@inetRouter ~]# ip link set eth1 down
```

Убедимся, что на ВМ `centralRouter` команда ping продолжает работать, а на ВМ `inetRouter` активное соединение переключилось на интерфейс `eth2`:

```
[root@centralRouter ~]# ping 192.168.255.1
PING 192.168.255.1 (192.168.255.1) 56(84) bytes of data.
64 bytes from 192.168.255.1: icmp_seq=1 ttl=64 time=0.504 ms
64 bytes from 192.168.255.1: icmp_seq=2 ttl=64 time=1.09 ms
64 bytes from 192.168.255.1: icmp_seq=3 ttl=64 time=0.921 ms
64 bytes from 192.168.255.1: icmp_seq=4 ttl=64 time=0.860 ms
64 bytes from 192.168.255.1: icmp_seq=5 ttl=64 time=0.720 ms
64 bytes from 192.168.255.1: icmp_seq=6 ttl=64 time=1.04 ms
64 bytes from 192.168.255.1: icmp_seq=7 ttl=64 time=1.26 ms
64 bytes from 192.168.255.1: icmp_seq=8 ttl=64 time=0.809 ms
64 bytes from 192.168.255.1: icmp_seq=9 ttl=64 time=0.715 ms
64 bytes from 192.168.255.1: icmp_seq=10 ttl=64 time=1.07 ms
64 bytes from 192.168.255.1: icmp_seq=11 ttl=64 time=0.828 ms
64 bytes from 192.168.255.1: icmp_seq=12 ttl=64 time=1.04 ms
64 bytes from 192.168.255.1: icmp_seq=13 ttl=64 time=1.09 ms
64 bytes from 192.168.255.1: icmp_seq=14 ttl=64 time=0.415 ms
64 bytes from 192.168.255.1: icmp_seq=15 ttl=64 time=1.65 ms
64 bytes from 192.168.255.1: icmp_seq=16 ttl=64 time=0.898 ms
64 bytes from 192.168.255.1: icmp_seq=17 ttl=64 time=0.529 ms
64 bytes from 192.168.255.1: icmp_seq=18 ttl=64 time=1.18 ms
64 bytes from 192.168.255.1: icmp_seq=19 ttl=64 time=1.11 ms
64 bytes from 192.168.255.1: icmp_seq=20 ttl=64 time=0.790 ms
64 bytes from 192.168.255.1: icmp_seq=21 ttl=64 time=0.857 ms
64 bytes from 192.168.255.1: icmp_seq=22 ttl=64 time=0.853 ms
64 bytes from 192.168.255.1: icmp_seq=23 ttl=64 time=1.23 ms
```

```
[root@inetRouter ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Peer Notification Delay (ms): 0

Slave Interface: eth1
MII Status: down
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: 08:00:27:d5:16:42
Slave queue ID: 0

Slave Interface: eth2
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 08:00:27:56:e3:29
Slave queue ID: 0
```

Для проверки настроек vlan запустим на ВМ `testClient1` и `testServer1` команды:

```
[vagrant@testClient1 ~]$ ping 10.10.10.1
```

```
[root@testServer1 ~]# tcpdump -i eth1 icmp -e
```

В выводе tcpdump на ВМ `testServer1` увидим, что пакеты тегированы номером vlan 100:

```
[root@testServer1 ~]# tcpdump -i eth1 icmp -e
dropped privs to tcpdump
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
12:38:44.467215 08:00:27:ac:59:91 (oui Unknown) > 08:00:27:15:2e:35 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, 10.10.10.254 > testServer1: ICMP echo request, id 24177, seq 6, length 64
12:38:44.467258 08:00:27:15:2e:35 (oui Unknown) > 08:00:27:ac:59:91 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, testServer1 > 10.10.10.254: ICMP echo reply, id 24177, seq 6, length 64
12:38:45.493408 08:00:27:ac:59:91 (oui Unknown) > 08:00:27:15:2e:35 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, 10.10.10.254 > testServer1: ICMP echo request, id 24177, seq 7, length 64
12:38:45.493477 08:00:27:15:2e:35 (oui Unknown) > 08:00:27:ac:59:91 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, testServer1 > 10.10.10.254: ICMP echo reply, id 24177, seq 7, length 64
12:38:46.517654 08:00:27:ac:59:91 (oui Unknown) > 08:00:27:15:2e:35 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, 10.10.10.254 > testServer1: ICMP echo request, id 24177, seq 8, length 64
12:38:46.517700 08:00:27:15:2e:35 (oui Unknown) > 08:00:27:ac:59:91 (oui Unknown), ethertype 802.1Q (0x8100), length 102: vlan 100, p 0, ethertype IPv4, testServer1 > 10.10.10.254: ICMP echo reply, id 24177, seq 8, length 64
```

Аналогично можно проверить настройки vlan для ВМ `testClient2` и `testServer2`.