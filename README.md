## Решение задания

Для проверки задания нужно запустить ВМ:

```
vagrant up
```

Будут запущены две ВМ: `nginx` и `ansible`.
Для ВМ `ansible` будет скопирован закрытый ssh ключ с помощью которого можно подключиться к ВМ `nginx`.

После старта ВМ `ansible` подключимся к ней через ssh:

```
vagrant ssh ansible
```

Все необходмое уже будет установлено.

Проверим возможность подключения ansible к ВМ nginx:

```
[vagrant@ansible ~]$ ansible nginx -m ping
nginx | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Убедились, что подключение проходит и можно выполнить установку nginx.

В домашнем каталоге пользователя `vagrant` расположены файлы настроек ansible.

Playbook для обычной установки nginx расположен в `playbooks/nginx.yml`.
Playbook для установки nginx через роль расположен в `playbooks/nginx_role.yml`.

Рассмотрим установку через роль, выполним команду и получим результат:

```
[vagrant@ansible ~]$ ansible-playbook playbooks/nginx_role.yml

PLAY [NGINX | Install and configure NGINX] ******************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************
ok: [nginx]

TASK [nginx : NGINX | Install EPEL Repo package from standart repo] *****************************************************************************
changed: [nginx]

TASK [nginx : NGINX | Install NGINX package from EPEL Repo] *************************************************************************************
changed: [nginx]

TASK [nginx : NGINX | Create NGINX config file from template] ***********************************************************************************
changed: [nginx]

RUNNING HANDLER [nginx : restart nginx] *********************************************************************************************************
changed: [nginx]

RUNNING HANDLER [nginx : reload nginx] **********************************************************************************************************
changed: [nginx]

PLAY RECAP **************************************************************************************************************************************
nginx                      : ok=6    changed=5    unreachable=0    failed=0
```

Nginx успешно установлен. Проверим его работу:

```
[vagrant@ansible ~]$ curl 192.168.11.102:8080
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
  <style rel="stylesheet" type="text/css">
...
```