## Решение задания

Для просмотра решения задания нужно выполнить команду:

```
vagrant up
```

Будет создана ВМ с дополнительными дисками для выполнения задания.
После создания ВМ выполнится inline provision скрипт, который установит все необходимое для работы с zfs.

### 1. Определить алгоритм с наилучшим сжатием.

Создадим zpool с именем `storage` на дисках `sdb` и `sdc` выполнив команду:

```
zpool create storage sdb sdc
```

Создадим четыре файловые системы с различными алгоритмами сжатия:

```
zfs create -po compression=gzip storage/compressed/gzip
zfs create -po compression=zle storage/compressed/zle
zfs create -po compression=lzjb storage/compressed/lzjb
zfs create -po compression=lz4 storage/compressed/lz4
```

Для определения алгоритма с наилучшим сжатием скачаем текстовый файл: 

```
curl -o enwik8.zip http://mattmahoney.net/dc/enwik8.zip
```

Распакуем файл в текущем каталоге:

```
unzip enwik8.zip
```

Текстовый файл `enwik8` имеет размер 100 МБ.
Скопируем файл на подготовленные файловые системы:

```
cp enwik8 /storage/compressed/gzip
cp enwik8 /storage/compressed/zle
cp enwik8 /storage/compressed/lzjb
cp enwik8 /storage/compressed/lz4
```

Получим коэффициенты сжатия для файловых систем:

```
zfs list -r -o compressratio,name storage/compressed | grep compressed/ | sort -rnb
2.66x  storage/compressed/gzip
1.72x  storage/compressed/lz4
1.44x  storage/compressed/lzjb
1.00x  storage/compressed/zle
```

Лучший коэффициент у файловой системы с алгоритмом сжатия gzip.

### 2. Определить настройки pool'а.

С помощью скрипта [gdrive.sh](./gdrive.sh) скачаем файл с импортированой файловой системой:

```
 bash gdrive.sh 1KRBNW33QWqbvbVHa3hLJivOAt60yukkg zfs_task1.tar.gz
```

Распакуем архив:

```
tar -xzvf zfs_task1.tar.gz
```

Проверим что zfs находит pool для импорта:

```
zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        otus                         ONLINE
          mirror-0                   ONLINE
            /root/zpoolexport/filea  ONLINE
            /root/zpoolexport/fileb  ONLINE
```

Pool `otus` можно импортировать, сделаем это командой:

```
zpool import -d zpoolexport otus storage
zpool list
NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
storage   480M  2.09M   478M        -         -     0%     0%  1.00x    ONLINE  -
```

Получим список настроек хранилища:

```
zfs list -o name,type,compression,used,avail,recordsize,checksum
NAME               TYPE        COMPRESS   USED  AVAIL  RECSIZE   CHECKSUM
storage            filesystem       zle  2.04M   350M     128K     sha256
storage/hometask2  filesystem       zle  1.88M   350M     128K     sha256
```

### 3. Найти сообщение от преподавателей.

С помощью скрипта [gdrive.sh](./gdrive.sh) cкачаем файл снимка:

```
bash gdrive.sh 1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG otus_task2.file
```

Создадим zpool с именем `otus`:

```
zpool create otus sdb
```

Восстановим снимок:

```
zfs receive otus/storage@task2 < otus_task2.file
```

Убедимся, что снимок восстановлен корректно:

```
zfs list
NAME           USED  AVAIL     REFER  MOUNTPOINT
otus          5.24M   827M     25.5K  /otus
otus/storage  4.99M   827M     4.68M  /otus/storage
```

Найдем файл с сообщением:

```
find /otus/storage/ -name "secret_message"
/otus/storage/task1/file_mess/secret_message
```

Файл существует, прочитаем его содержимое:

```
cat /otus/storage/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```