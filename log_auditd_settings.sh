# Включение прослушивания порта 60 для приема сообщений аудита с других хостов.
sed -i "s/##tcp_listen_port = 60/tcp_listen_port = 60/" /etc/audit/auditd.conf

# Перезапуск службы auditd.
service auditd restart