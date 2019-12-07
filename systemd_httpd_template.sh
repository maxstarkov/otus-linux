cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
sed -i 's/EnvironmentFile=\/etc\/sysconfig\/httpd.*/EnvironmentFile=\/etc\/sysconfig\/httpd-%i/' /etc/systemd/system/httpd@.service
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd_first.conf
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd_second.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd_first.conf
sed -i 's/Listen 80/Listen 8008/' /etc/httpd/conf/httpd_second.conf
echo "PidFile /var/run/httpd_first.pid" >> /etc/httpd/conf/httpd_first.conf
echo "PidFile /var/run/httpd_second.pid" >> /etc/httpd/conf/httpd_second.conf
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-first
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-second
sed -i 's/#OPTIONS=.*/OPTIONS=-f conf\/httpd_first.conf/' /etc/sysconfig/httpd-first
sed -i 's/#OPTIONS=.*/OPTIONS=-f conf\/httpd_second.conf/' /etc/sysconfig/httpd-second
systemctl start httpd@first.service
systemctl start httpd@second.service
