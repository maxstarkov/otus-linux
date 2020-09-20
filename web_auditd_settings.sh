# Дополнительная настройка сообщений лога auditd.
# Включение расширенного формата сообщений и вывода имени хоста.
sed -i "s/log_format = RAW/log_format = ENRICHED/" /etc/audit/auditd.conf
sed -i "s/name_format = NONE/name_format = HOSTNAME/" /etc/audit/auditd.conf

# Установка плагинов для сервиса audispd, который является мультиплексором сообщений сервиса auditd.
yum -y install audispd-plugins

# Активация плагина отправки сообщений auditd на удаленный сервер.
sed -i "s/active = no/active = yes/" /etc/audisp/plugins.d/au-remote.conf

# Настройка адреса сервера для сбора логов.
sed -i "s/remote_server =/remote_server = 192.168.11.102/" /etc/audisp/audisp-remote.conf

# Добавление настройки для отслеживания изменений файла конфигурации nginx.
echo "-w /etc/nginx/nginx.conf -p wa -k nginx_conf_change" >> /etc/audit/rules.d/audit.rules

# Перезапуск службы auditd.
service auditd restart