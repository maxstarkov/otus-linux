cp /vagrant/watchlog /etc/sysconfig
cp /vagrant/watchlog.{service,timer} /etc/systemd/system
mkdir -p /opt
cp /vagrant/watchlog.sh /opt
chmod +x /opt/watchlog.sh
echo "ALERT. Test log message" > /var/log/watchlog.log
systemctl daemon-reload
systemctl enable watchlog.timer
systemctl start watchlog.timer
