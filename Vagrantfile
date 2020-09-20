# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure("2") do |config|

        config.vbguest.auto_update = false
        
        config.vm.define "web" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "web"

                box.vm.network "private_network", ip: '192.168.11.101'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end

                box.vm.provision "shell", inline: <<-SHELL
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                SHELL

                box.vm.provision "shell", inline: <<-SHELL
                echo "*.crit @@192.168.11.102:514" > /etc/rsyslog.d/crit.conf
                systemctl restart rsyslog
                yum install -y epel-release
                yum install -y nginx
                systemctl start nginx
                cp /vagrant/nginx_log.conf /etc/nginx/default.d/log.conf
                systemctl restart nginx
                SHELL

                box.vm.provision "shell", path: "web_auditd_settings.sh"

        end

        config.vm.define "log" do |box|

                box.vm.box = "centos/7"
                box.vm.host_name = "log"

                box.vm.network "private_network", ip: '192.168.11.102'

                box.vm.provider :virtualbox do |vb|
                        vb.customize ["modifyvm", :id, "--memory", "1024"]
                end

                box.vm.provision "shell", inline: <<-SHELL
                        mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
                SHELL

                box.vm.provision "shell", inline: <<-SHELL
                cp /vagrant/rsyslog_server.conf /etc/rsyslog.conf
                systemctl restart rsyslog
                SHELL

                box.vm.provision "shell", path: "log_auditd_settings.sh"

        end

end