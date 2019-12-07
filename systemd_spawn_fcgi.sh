yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
sed -i 's/#SOCKET=/SOCKET=/;s/#OPTIONS=/OPTIONS=/' /etc/sysconfig/spawn-fcgi
cp /vagrant/spawn-fcgi.service /etc/systemd/system
systemctl start spawn-fcgi.service
