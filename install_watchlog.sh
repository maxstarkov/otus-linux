yum -y install mailx
mkdir -p /opt/watchlog
cp /vagrant/watchlog.sh /vagrant/prepare_log.sh /opt/watchlog
cat /vagrant/access.log | source /opt/watchlog/prepare_log.sh > /vagrant/access_new.log
echo "* * * * * source /opt/watchlog/watchlog.sh 5 5 /vagrant/access_new.log" | crontab