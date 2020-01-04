# Установим и запустим nginx.
yum install -y epel-release

yum install -y nginx

systemctl start nginx

# Создадим каталог репозитория rpm пакетов.
mkdir /usr/share/nginx/html/rpm_repo

cd ~

# Скопируем в него собраный пакет.
cp ~/rpmbuild/RPMS/noarch/lavg-0.1-1.el7.noarch.rpm /usr/share/nginx/html/rpm_repo/

# Создадим репозиторий.
createrepo /usr/share/nginx/html/rpm_repo/

# Переопределим настройки корневого пути в отдельном файле.
cat > /etc/nginx/default.d/default.conf <<-EOF
location / {
    root /usr/share/nginx/html;
    index index.html index.htm;
    autoindex on;
}
EOF

# Удалим из исходной конфигурации настройки корневого пути (если они там есть).
sed -i '/location \/ {/,+1d' /etc/nginx/nginx.conf

# Перезапустим nginx.
nginx -s reload

# Добавим репозиторий в состав доступных репозиториев yum.
cat >> /etc/yum.repos.d/otus.repo <<-EOF
[otus]
name=otus-linux
baseurl=http://localhost/rpm_repo/
gpgcheck=0
enabled=1
EOF

# Удалим предыдущую установку пакета lavg.
rpm -q lavg &>/dev/null && rpm -e lavg

# Установим lavg из локального репозитория.
yum install -y lavg